#!/usr/bin/env ruby

# frozen_string_literal: true

require "csv"
require "rexml/document"

class WeatherStationData
  FILE_LAYOUT = {
    SOURCE_ID: [1, 20],
    SOURCE: [22, 31],
    BEGIN_DATE: [33, 40],
    END_DATE: [42, 49],
    STATION_STATUS: [51, 70],
    NCDCSTN_ID: [72, 91],
    ICAO_ID: [93, 112],
    WBAN_ID: [114, 133],
    FAA_ID: [135, 154],
    NWSLI_ID: [156, 175],
    WMO_ID: [177, 196],
    COOP_ID: [198, 217],
    TRANSMITTAL_ID: [219, 238],
    GHCND_ID: [240, 259],
    NAME_PRINCIPAL: [261, 360],
    NAME_PRINCIPAL_SHORT: [362, 391],
    NAME_COOP: [393, 492],
    NAME_COOP_SHORT: [494, 523],
    NAME_PUBLICATION: [525, 624],
    NAME_ALIAS: [626, 725],
    NWS_CLIM_DIV: [727, 736],
    NWS_CLIM_DIV_NAME: [738, 777],
    STATE_PROV: [779, 788],
    COUNTY: [790, 839],
    NWS_ST_CODE: [841, 842],
    FIPS_COUNTRY_CODE: [844, 845],
    FIPS_COUNTRY_NAME: [847, 946],
    NWS_REGION: [948, 977],
    NWS_WFO: [979, 988],
    ELEV_GROUND: [990, 1029],
    ELEV_GROUND_UNIT: [1031, 1050],
    ELEV_BAROM: [1052, 1091],
    ELEV_BAROM_UNIT: [1093, 1112],
    ELEV_AIR: [1114, 1153],
    ELEV_AIR_UNIT: [1155, 1174],
    ELEV_ZERODAT: [1176, 1215],
    ELEV_ZERODAT_UNIT: [1217, 1236],
    ELEV_UNK: [1238, 1277],
    ELEV_UNK_UNIT: [1279, 1298],
    LAT_DEC: [1300, 1319],
    LON_DEC: [1321, 1340],
    LAT_LON_PRECISION: [1342, 1351],
    RELOCATION: [1353, 1414],
    UTC_OFFSET: [1416, 1431],
    OBS_ENV: [1433, 1472],
    PLATFORM: [1474, 1573],
    GHCNMLT_ID: [1575, 1594],
    COUNTY_FIPS_CODE: [1596, 1600],
    DATUM_HORIZONTAL: [1602, 1631],
    DATUM_VERTICAL: [1633, 1662],
    LAT_LON_SOURCE: [1664, 1763],
    IGRA_ID: [1765, 1784],
    HPD_ID: [1786, 1805],
    GHCNH_ID: [1807, 1826]
  }.freeze

  CSV_MAPPING = {
    icao_id: :ICAO_ID,
    name: :NAME_PRINCIPAL,
    state: :STATE_PROV,
    wban_id: :WBAN_ID,
    wmo_id: :WMO_ID,
    lat: :LAT_DEC,
    lng: :LON_DEC,
    elevation_feet: [:ELEV_GROUND, ->(elevation) { (elevation.to_f * 0.3048).round(2) if elevation }],
  }.freeze

  def initialize(path)
    @path = path
  end

  def to_csv(output = $stdout)
    csv = CSV.new(output)
    csv << CSV_MAPPING.keys
    weather_stations.each_value do |station|
      csv << CSV_MAPPING.keys.collect { |key| station[key] }
    end
  end

  private

  def weather_stations
    stations = current_obs_stations
    ids = stations.keys

    File.open(File.join(@path, "mshr_enhanced.txt")) do |file|
      file.each_line do |line|
        icao_id = field(:ICAO_ID, line)
        station = stations[icao_id]
        next unless station

        unless field(:FIPS_COUNTRY_CODE, line) == "US"
          stations.delete(icao_id)
          next
        end

        end_date = field(:END_DATE, line)
        next if end_date.empty? || Date.parse(end_date) < Date.today

        ids.delete(icao_id)

        CSV_MAPPING.each do |csv_name, source|
          next if station[csv_name]

          source, formatter = Array(source)
          value = field(source, line)
          value = formatter.call(value) if formatter

          station[csv_name] = value unless value == ""
        end
      end
    end

    ids.each do |icao_id|
      stations.delete(icao_id)
    end

    stations
  end

  def current_obs_stations
    stations = {}

    xml_data = File.read(File.join(@path, "current_obs.xml"))
    doc = REXML::Document.new(xml_data)
    doc.elements.each("//station") do |station_element|
      station = {}

      station_element.elements.each do |node|
        case node.name
        when "station_id"
          station[:icao_id] = node.text
        when "station_name"
          station[:name] = node.text
        when "latitude"
          station[:lat] = node.text.to_f
        when "longitude"
          station[:lng] = node.text.to_f
        when "state"
          station[:state] = node.text
        end
      end
      stations[station[:icao_id]] = station
    end

    stations
  end

  def field(name, line)
    offset = FILE_LAYOUT[name][0] - 1
    length = FILE_LAYOUT[name][1] - offset
    line[offset, length].strip
  end
end

if $0 == __FILE__
  WeatherStationData.new(ARGV[0]).to_csv
end

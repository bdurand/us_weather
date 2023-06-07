# frozen_string_literal: true

module USWeather
  module WeatherAPI
    BASE_URL = "https://api.weather.gov/"

    COUNTY_FIPS_PATTERN = /\A\d{5}\z/

    class << self
      def latest_observation(station_id)
        result = get("/stations/#{station_id}/observations/latest")
        return nil unless result

        observation_attributes(result)
      end

      def each_station(&block)
        path = "/stations?limit=500"

        loop do
          result = get(path)
          results = result["@graph"]
          break if results.empty?

          results.each do |info|
            next unless info["@type"] == "wx:ObservationStation"

            yield station_attributes(info)
          end

          next_page = result.dig("pagination", "next")
          break unless next_page

          path = URI(next_page).request_uri
        end
      end

      def each_forecast_zone(&block)
        get("/zones", type: "forecast", effective: effective_time).dig("@graph").each do |info|
          yield zone_attributes(info)
        end
      end

      def effective_time
        "#{Time.now.utc.to_date.iso8601}T00:00:00Z"
      end

      private

      def get(path, params = nil)
        body = nil

        uri = URI.join(BASE_URL, path)
        uri.query = URI.encode_www_form(params) if params
        use_ssl = (uri.scheme == "https")

        puts "GET #{uri}"

        Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl, open_timeout: USWeather.open_timeout, read_timeout: USWeather.read_timeout) do |http|
          response = http.request(request(uri))
          if response.is_a?(Net::HTTPSuccess)
            body = response.body
            if response["Content-Encoding"] == "gzip"
              body = Zlib::GzipReader.new(StringIO.new(body)).read
            end
          elsif response.is_a?(Net::HTTPNotFound)
            return nil
          else
            raise HttpError.new("#{response.code} #{response.message}")
          end
        end

        JSON.parse(body)
      end

      def request(uri)
        request = Net::HTTP::Get.new(uri)
        request["Accept"] = "application/ld+json"
        request["Accept-Encoding"] = "gzip"
        request["User-Agent"] = USWeather.user_agent
        request
      end

      def icon_code(icon_url)
        return nil unless icon_url
        URI(icon_url).path.split("/").last
      end

      def state_code(county_id)
        return nil unless county_id
        county_id[0..1]
      end

      def county_fips(county_id)
        state = state_code(county_id)
        return nil unless state

        fips = "#{State.fips_code(state)}#{county_id[3..5]}"
        return fips if fips.match?(COUNTY_FIPS_PATTERN)
      end

      def observation_attributes(result)
        observation = {}

        observation[:station_id] = result["station"].split("/").last
        observation[:observed_at] = Time.iso8601(result["timestamp"])
        observation[:description] = result["textDescription"]
        observation[:icon_code] = icon_code(result["icon"])
        observation[:temperature_celcius] = result.dig("temperature", "value")&.round(2)
        observation[:dewpoint_celcius] = result.dig("dewpoint", "value")&.round(2)
        humidity = result.dig("relativeHumidity", "value")&.round(4)
        observation[:relative_humidity] = humidity / 100 if humidity
        observation[:wind_direction_degrees] = result.dig("windDirection", "value")
        observation[:wind_speed_kph] = result.dig("windSpeed", "value")&.round(2)
        observation[:wind_gust_kph] = result.dig("windGust", "value")&.round(2)
        observation[:barometric_pressure_pascals] = result.dig("barometricPressure", "value")
        observation[:sea_level_pressure_pascals] = result.dig("seaLevelPressure", "value")
        observation[:visibility_meters] = result.dig("visibility", "value")
        observation[:precipitation_1hr_mm] = result.dig("precipitationLastHour", "value")
        observation[:precipitation_3hr_mm] = result.dig("precipitationLast3Hours", "value")
        observation[:precipitation_6hr_mm] = result.dig("precipitationLast6Hours", "value")
        observation[:heat_index_celcius] = result.dig("heatIndex", "value")&.round(2)
        observation[:wind_chill_celcius] = result.dig("windChill", "value")&.round(2)

        observation
      end

      def station_attributes(info)
        station = {}

        station[:id] = info["stationIdentifier"]
        station[:name] = info["name"]
        station[:time_zone] = info["timeZone"]

        point = info["geometry"]
        if point
          station[:lnglat] = RGeo::WKRep::WKTParser.new(geo_factory).parse(point)
        end

        county_id = info["county"]&.split("/")&.last
        station[:county_id] = county_id
        station[:state_code] = state_code(county_id)
        station[:county_fips_code] = county_fips(county_id)

        station[:forecast_zone_id] = info["forecast"]&.split("/")&.last
        station[:fire_zone_id] = info["fireWeatherZone"]&.split("/")&.last

        station
      end

      def zone_attributes(info)
        zone = {}

        zone[:id] = info["id"].split("/").last
        zone[:name] = info["name"]

        zone_details = get(info["@id"])
        $info = zone_details
        geometry = zone_details&.dig("geometry")
        if geometry
          area = RGeo::WKRep::WKTParser.new(geo_factory).parse(geometry)
          zone[:area] = area
        end

        zone
      end

      def geo_factory
        RGeo::Geographic.spherical_factory(srid: 4326)
      end
    end
  end
end

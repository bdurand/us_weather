# frozen_string_literal: true

require_relative "application_record"

module USWeather
  class Observation < ApplicationRecord
    self.table_name = "us_weather_observations"

    ICON_BASE_URI = URI("https://api.weather.gov//icons/land/").freeze
    ICON_SIZES = %w[small medium large].freeze
    REFRESH_INTERVAL = 15.minutes

    METERS_PER_MILE = 1609.34
    MILLIMETERS_PER_INCH = 25.4
    PASCALS_PER_INCH_OF_MERCURY = 3386.39
    MPH_PER_KPH = 0.621371

    belongs_to :station, class_name: "USWeather::Station", inverse_of: :observations, optional: true

    validates :station_id, presence: true, length: {maximum: 12}
    validates :observed_at, presence: true
    validates :description, presence: true, length: {maximum: 100}
    validates :icon_code, length: {maximum: 20, allow_nil: true}
    validates :elevation_meters, numericality: {allow_nil: true}
    validates :temperature_celcius, numericality: {allow_nil: true}
    validates :dewpoint_celcius, numericality: {allow_nil: true}
    validates :relative_humidity, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
    validates :wind_speed_kph, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
    validates :wind_gust_kph, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
    validates :wind_direction_degrees, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0, less_than: 360}
    validates :barometric_pressure_pascals, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :heat_index_celcius, numericality: {allow_nil: true}
    validates :wind_chill_celcius, numericality: {allow_nil: true}
    validates :visibility_meters, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}

    class << self
      def latest(station_or_id)
        station_id = (station_or_id.is_a?(USWeather::Station) ? station_or_id.id : station_or_id)

        existing = where(station_id: station_id).where(arel_table[:observed_at].gt(REFRESH_INTERVAL.ago)).order(observed_at: :desc).first
        return existing if existing

        attributes = WeatherAPI.latest_observation(station_id)
        return nil unless attributes

        existing = where(station_id: station_id, observed_at: attributes[:observed_at]).first
        return existing if existing

        new(attributes.slice(*column_names))
      end

      def latest!(weather_station)
        observation = latest(weather_station)
        raise ArgumentError.new("No observation found for #{weather_station}") unless observation
        observation.save! if observation.new_record?
        observation
      end
    end

    def temperature_fahrenheit
      celcius_to_fahrenheit(temperature_celcius)
    end

    def dewpoint_fahrenheit
      celcius_to_fahrenheit(dewpoint_celcius)
    end

    def wind_speed_mph
      kph_to_mph(wind_speed_kph)
    end

    def wind_gust_mph
      kph_to_mph(wind_gust_kph)
    end

    def barometric_pressure_inches
      pascals_to_inches_of_mercury(barometric_pressure_pascals)
    end

    def sea_level_pressure_inches
      pascals_to_inches_of_mercury(sea_level_pressure_pascals)
    end

    def precipitation_1hr_inches
      millimeters_to_inches(precipitation_1hr_mm)
    end

    def precipitation_3hr_inches
      millimeters_to_inches(precipitation_3hr_mm)
    end

    def precipitation_6hr_inches
      millimeters_to_inches(precipitation_6hr_mm)
    end

    def visibility_miles
      meters_to_miles(visibility_meters)
    end

    def icon_url(size: "medium")
      return nil unless icon_code
      size = "medium" unless ICON_SIZES.include?(size.to_s)
      ICON_BASE_URI.join("#{daytime? ? "day" : "night"}/#{icon_code}?size=#{size}").to_s
    end

    def daytime?
      return nil unless weather_station
      observed_at.between?(weather_station.sunrise(observed_at), weather_station.sunset(observed_at))
    end

    def nighttime?
      return nil unless weather_station
      !daytime?
    end

    private

    def celcius_to_fahrenheit(celcius)
      return nil unless celcius
      (celcius * 9 / 5) + 32
    end

    def millimeters_to_inches(millimeters)
      return nil unless millimeters
      millimeters / MILLIMETERS_PER_INCH
    end

    def meters_to_miles(meters)
      return nil unless meters
      meters / METERS_PER_MILE
    end

    def pascals_to_inches_of_mercury(pascals)
      return nil unless pascals
      pascals / PASCALS_PER_INCH_OF_MERCURY
    end

    def kph_to_mph(kph)
      return nil unless kph
      kph * MPH_PER_KPH
    end
  end
end

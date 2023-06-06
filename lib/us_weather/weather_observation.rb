# frozen_string_literal: true

require_relative "application_record"

module USWeather
  class WeatherObservation < ApplicationRecord
    self.table_name = "us_weather_observations"

    ICON_BASE_URI = URI("https://api.weather.gov//icons/land/").freeze
    ICON_SIZES = %w[small medium large].freeze
    REFRESH_INTERVAL = 15.minutes

    belongs_to :weather_station, class_name: "USWeather::WeatherStation", primary_key: "icao_id", foreign_key: "icao_id", inverse_of: :weather_observations, optional: true

    validates :icao_id, presence: true, length: {maximum: 5}
    validates :observed_at, presence: true
    validates :description, presence: true, length: {maximum: 100}
    validates :icon_code, length: {maximum: 20, allow_nil: true}
    validates :temperature_celcius, numericality: {allow_nil: true}
    validates :dewpoint_celcius, numericality: {allow_nil: true}
    validates :relative_humidity, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
    validates :wind_speed_kph, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
    validates :wind_gust_kph, numericality: {allow_nil: true, greater_than_or_equal_to: 0}
    validates :wind_direction_degrees, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0, less_than: 360}
    validates :barometric_pressure_pascals, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :sea_level_pressure_pascals, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :heat_index_celcius, numericality: {allow_nil: true}
    validates :wind_chill_celcius, numericality: {allow_nil: true}
    validates :precipitation_1hr_mm, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :precipitation_3hr_mm, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :precipitation_6hr_mm, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :visibility_meters, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}

    class << self
      def current(weather_station)
        icao_id = (weather_station.is_a?(USWeather::WeatherStation) ? weather_station.icao_id : weather_station)

        existing = where(icao_id: icao_id).where(arel_table[:observed_at].gt(REFRESH_INTERVAL.ago)).order(observed_at: :desc).first
        return existing if existing

        observation = NoaaObservation.new(icao_id).fetch
        return nil unless observation

        existing = where(icao_id: icao_id, observed_at: observation.observed_at).first
        return existing if existing

        observation
      end

      def current!(weather_station)
        observation = current(weather_station)
        raise ArgumentError.new("No observation found for #{weather_station}") unless observation
        observation.save! if observation.new_record?
        observation
      end
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
  end
end

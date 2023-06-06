# frozen_string_literal: true

require_relative "application_record"

module USWeather
  class WeatherStation < ApplicationRecord
    self.table_name = "us_weather_stations"
    self.primary_key = "icao_id"

    has_many :observations, class_name: "USWeather::WeatherObservation", primary_key: "icao_id", foreign_key: "icao_id", inverse_of: :weather_station

    validates :icao_id, presence: true, length: {maximum: 5}
    validates :name, presence: true, length: {maximum: 100}
    validates :state, presence: true, length: {is: 2}
    validates :lat, presence: true, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}
    validates :lng, presence: true, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}
    validates :elevation_meters, presence: true, numericality: true
    validates :wban_id, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}
    validates :wmo_id, numericality: {only_integer: true, allow_nil: true, greater_than_or_equal_to: 0}

    def current_observation
      USWeather::WeatherObservation.current(self)
    end

    def current_observation!
      USWeather::WeatherObservation.current!(self)
    end

    def sunrise(date)
      Sun.sunrise(date, lat, lng)
    end

    def sunset(date)
      Sun.sunset(date, lat, lng)
    end
  end
end

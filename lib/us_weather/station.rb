# frozen_string_literal: true

require_relative "application_record"

module USWeather
  class Station < ApplicationRecord
    self.table_name = "us_weather_stations"

    scope :active, -> { where(active: true) }

    scope :order_by_distance, ->(lat, lng) {
      point = geo_factory.point(lng, lat)
      order(Arel.sql"#{table_name}.lnglat::geometry <-> ST_GeographyFromText('#{point.to_s}')")
    }

    belongs_to :forecast_zone, class_name: "USWeather::Zone", foreign_key: "forecast_zone_id", inverse_of: :observation_stations, optional: true
    has_many :observations, class_name: "USWeather::Observation", inverse_of: :station

    validates :id, presence: true, length: {maximum: 12}
    validates :name, presence: true, length: {maximum: 100}
    validates :county_id, length: {maximum: 6, allow_nil: true}
    validates :county_fips_code, length: {is: 5, allow_nil: true}
    validates :state_code, length: {is: 2, allow_nil: true}

    class << self
      def closest_to(lat, lng)
        zone = Zone.select([:id, :name]).closest_to(lat, lng)
        return nil unless zone

        zone.observation_stations.order_by_distance(lat, lng).first
      end
    end

    def latest_observation
      USWeather::Observation.latest(self)
    end

    def latest_observation!
      USWeather::Observation.latest!(self)
    end

    def lat
      lnglat&.y
    end

    def lng
      lnglat&.x
    end

    def sunrise(date)
      Sun.sunrise(date, lat, lng)
    end

    def sunset(date)
      Sun.sunset(date, lat, lng)
    end

    def distance_to(lat:, lng:)
      factory = geo_factory(srid: 4326)
      point_1 = factory.point(self.lng, self.lat)
      point_2 = factory.point(lng, lat)
      factory.spherical_distance(point_1, point_2).round(2)
    end
  end
end

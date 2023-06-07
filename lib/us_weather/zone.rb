# frozen_string_literal: true

require_relative "application_record"

module USWeather
  class Zone < ApplicationRecord
    self.table_name = "us_weather_zones"

    METERS_PER_MILE = 1609.34

    scope :containing, ->(lat, lng) {
      point = geo_factory.point(lng, lat)
      where(Arel.sql("ST_Covers(#{table_name}.area, ST_GeographyFromText('#{point.to_s}'))"))
    }

    scope :order_by_distance, ->(lat, lng) {
      point = geo_factory.point(lng, lat)
      where(Arel.sql("ST_DWithin(#{table_name}.area, ST_GeographyFromText('#{point.to_s}'), #{})")).
        order(Arel.sql("#{table_name}.area <-> ST_GeographyFromText('#{point.to_s}')")).limit(1)
    }

    has_many :observation_stations, class_name: "USWeather::Station", foreign_key: "forecast_zone_id", inverse_of: :forecast_zone

    validates :id, presence: true, length: {maximum: 12}
    validates :name, presence: true, length: {maximum: 200}

    class << self
      def closest_to(lat, lng)
        zone = containing(lat, lng).first
        unless zone
          zone = order_by_distance(lat, lng).first
        end
        zone
      end
    end
  end
end

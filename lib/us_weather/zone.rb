# frozen_string_literal: true

require_relative "application_record"

module USWeather
  class Zone < ApplicationRecord
    self.table_name = "us_weather_zones"

    scope :active, -> { where(active: true) }

    scope :containing, ->(lat, lng) {
      point = geo_factory.point(lng, lat)
      where(Arel.sql("ST_Covers(#{table_name}.area, ST_GeographyFromText('#{point}'))"))
    }

    scope :order_by_distance, ->(lat, lng) {
      point = geo_factory.point(lng, lat)
      where(Arel.sql("ST_DWithin(#{table_name}.area, ST_GeographyFromText('#{point}'), )"))
        .order(Arel.sql("#{table_name}.area <-> ST_GeographyFromText('#{point}')")).limit(1)
    }

    has_many :observation_stations, class_name: "USWeather::Station", foreign_key: "forecast_zone_id", inverse_of: :forecast_zone

    validates :id, presence: true, length: {maximum: 12}
    validates :name, presence: true, length: {maximum: 200}

    class << self
      def closest_to(lat:, lng:)
        zone = active.containing(lat, lng).first
        zone ||= active.order_by_distance(lat, lng).first
        zone
      end
    end

    def import
      all_ids = active.pluck(:id).to_set
      WeatherAPI.each_forecast_zone do |attributes|
        zone = find_or_initialize_by(id: attributes[:id])
        zone.assign_attributes(attributes)
        zone.save!
        all_ids.delete(zone.id)
      end

      all_ids.each do |id|
        zone = find_by(id: id, active: true)
        if zone
          zone.active = false
          zone.save(validate: false)
        end
      end
    end
  end
end

# frozen_string_literal: true

module USWeather
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def geo_factory
        @geo_factory ||= RGeo::Geographic.spherical_factory(srid: 4326)
      end
    end
  end
end

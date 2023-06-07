# frozen_string_literal: true

module USWeather
  class Engine < Rails::Engine
    config.before_eager_load do
      require_relative "zone"
      require_relative "station"
      require_relative "observation"
    end
  end
end
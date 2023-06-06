# frozen_string_literal: true

module USWeather
  class Engine < Rails::Engine
    config.before_eager_load do
      require_relative "weather_station"
      require_relative "weather_observation"
    end
  end
end
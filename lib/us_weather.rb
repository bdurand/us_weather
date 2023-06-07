# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require "sun"
require "rgeo"

require_relative "us_weather/version"
require_relative "us_weather/observation"
require_relative "us_weather/state"
require_relative "us_weather/station"
require_relative "us_weather/weather_api"
require_relative "us_weather/zone"

require_relative "us_weather/engine" if defined?(Rails::Engine)

module USWeather
  class HttpError < StandardError
  end

  class << self
    attr_writer :user_agent

    def user_agent
      @user_agent ||= "ruby us_weather/#{VERSION}"
    end

    attr_writer :open_timeout

    def open_timeout
      @open_timeout ||= 10.0
    end

    attr_writer :read_timeout

    def read_timeout
      @read_timeout ||= 10.0
    end

    attr_writer :logger

    def logger
      @logger ||= Rails.logger if defined?(Rails.logger)
    end
  end
end

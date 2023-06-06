# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

require "active_record"
require 'webmock/rspec'

require "simplecov"
SimpleCov.start do
  add_filter ["/spec/"]
end

Bundler.require(:default, :test)

ActiveRecord::Base.establish_connection("adapter" => "sqlite3", "database" => ":memory:")

WebMock.disable_net_connect!(allow_localhost: false)

require_relative "../lib/us_weather"

Dir.glob(File.expand_path("../db/migrate/*.rb", __dir__)).sort.each do |path|
  require(path)
  class_name = File.basename(path).sub(/\.rb\z/, "").split("_", 2).last.camelcase
  class_name.constantize.migrate(:up)
end

require_relative "../lib/us_weather/weather_station"
require_relative "../lib/us_weather/weather_observation"

RSpec.configure do |config|
  config.order = :random

  config.before do
    USWeather::WeatherStation.delete_all
    USWeather::WeatherObservation.delete_all
  end
end

# frozen_string_literal: true

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" if File.exist?(ENV["BUNDLE_GEMFILE"])

require "active_record"
require "webmock/rspec"

require "simplecov"
SimpleCov.start do
  add_filter ["/spec/"]
end

Bundler.require(:default, :test)

Dotenv.load(".env")

ActiveRecord::Base.establish_connection("url" => ENV.fetch("DATABASE_URL"), "database" => "us_weather_test")
ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS postgis")
%w[us_weather_stations us_weather_zones us_weather_observations].each do |table_name|
  if ActiveRecord::Base.connection.table_exists?(table_name)
    ActiveRecord::Base.connection.drop_table(table_name)
  end
end

WebMock.disable_net_connect!(allow_localhost: false)

require_relative "../lib/us_weather"

Dir.glob(File.expand_path("../db/migrate/*.rb", __dir__)).sort.each do |path|
  require(path)
  class_name = File.basename(path).sub(/\.rb\z/, "").split("_", 2).last.camelcase
  class_name.constantize.migrate(:up)
end

RSpec.configure do |config|
  config.order = :random

  config.before do
    USWeather::Zone.delete_all
    USWeather::Station.delete_all
    USWeather::Observation.delete_all
  end
end

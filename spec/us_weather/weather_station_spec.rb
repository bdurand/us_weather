# frozen_string_literal: true

require_relative "../spec_helper"

describe USWeather::WeatherStation do
  describe "sunrise" do
    it "returns the sunrise time" do
      expect(USWeather::WeatherStation.new("KJFK").sunrise).to eq("6:00 am")
    end
  end

  describe "sunset" do
    it "returns the sunset time" do
      expect(USWeather::WeatherStation.new("KJFK").sunset).to eq("7:00 pm")
    end
  end

  describe "current_observation" do
    it "returns the current observation"
  end

  describe "current_observation!" do
    it "fetches the current observation and saves it"
  end
end

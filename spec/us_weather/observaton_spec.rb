# frozen_string_literal: true

require_relative "../spec_helper"

describe USWeather::Observation do
  describe "latest" do
    it "returns the current observation" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").
        to_return(status: 200, body: File.read("spec/fixtures/KCCR.json"), headers: {"Content-Type" => "application/ld+json"})

      observation = USWeather::Observation.latest("KCCR")
      expect(observation.station_id).to eq("KCCR")
      expect(observation).to_not be_persisted
    end

    it "returns an existing observation if it already exists" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").
        to_return(status: 200, body: File.read("spec/fixtures/KCCR.json"), headers: {"Content-Type" => "application/ld+json"})

      time = Time.parse("2023-06-06T02:53:00+00:00")
      existing_observation = USWeather::Observation.create!(station_id: "KCCR", observed_at: time, description: "Clear")
      observation = USWeather::Observation.latest("KCCR")
      expect(observation).to eq(existing_observation)
    end

    it "returns the most recent observation if it was from the past 15 minutes" do
      time = 14.minutes.ago
      existing_observation = USWeather::Observation.create!(station_id: "KCCR", observed_at: time, description: "Clear")
      observation = USWeather::Observation.latest("KCCR")
      expect(observation).to eq(existing_observation)
    end

    it "queries the NOAA API if the more recent observation is older than 15 minutes" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").
        to_return(status: 200, body: File.read("spec/fixtures/KCCR.json"), headers: {"Content-Type" => "application/ld+json"})

      time = 16.minutes.ago
      existing_observation = USWeather::Observation.create!(station_id: "KCCR", observed_at: time, description: "Clear")
      observation = USWeather::Observation.latest("KCCR")
      expect(observation).to_not eq(existing_observation)
    end

    it "returns nil if the NOAA API returns a 404" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").to_return(status: 404)
      expect(USWeather::Observation.latest("KCCR")).to be_nil
    end
  end

  describe "latest!" do
    it "fetches the current observation and saves it" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").
        to_return(status: 200, body: File.read("spec/fixtures/KCCR.json"), headers: {"Content-Type" => "application/ld+json"})

      observation = USWeather::Observation.latest!("KCCR")
      expect(observation).to be_persisted
    end

    it "raises an error if the latest observation cannot be found" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").to_return(status: 404)
      expect { USWeather::Observation.latest!("KCCR") }.to raise_error(ArgumentError)
    end
  end

  describe "icon_url" do
    it "returns the URL for the icon"
  end

  describe "daytime?" do
    it "returns true if the observation is during the day"
    it "returns false if the observation is during the night"
  end

  describe "convesions" do
    it "returns the temperature in Fahrenheit"
    it "returns the dewpoint in Fahrenheit"
    it "returns the wind speed in miles per hour"
    it "returns the wind gust in miles per hour"
    it "returns the barometric pressure in inches of mercury"
    it "returns the sea level pressure in inches of mercury"
    it "returns the barometric pressure in atmospheres"
    it "returns the sea level pressure in atmospheres"
    it "returns the heat index in Fahrenheit"
    it "returns the wind chill in Fahrenheit"
    it "returns the visibility in miles"
    it "returns the precipitation in inches"
  end
end

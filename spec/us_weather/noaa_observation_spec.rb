# frozen_string_literal: true

require_relative "../spec_helper"

describe USWeather::NoaaObservation do
  describe "#fetch" do
    it "gets data from the NOAA API and returns an observation" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").
        with(headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"}).
        to_return(status: 200, body: File.read("spec/fixtures/KCCR.json"), headers: {"Content-Type" => "application/ld+json"})

      observation = USWeather::NoaaObservation.new("KCCR").fetch
      expect(observation.icao_id).to eq("KCCR")
      expect(observation.observed_at).to eq(Time.parse("2023-06-06T02:53:00+00:00"))
      expect(observation.description).to eq("Clear")
      expect(observation.icon_code).to eq("skc")
      expect(observation.temperature_celcius.round(1)).to eq(15.6)
      expect(observation.dewpoint_celcius.round(1)).to eq(10.6)
      expect(observation.relative_humidity.round(3)).to eq(0.721)
      expect(observation.wind_direction_degrees).to eq(280)
      expect(observation.wind_speed_kph.round(1)).to eq(18.4)
      expect(observation.wind_gust_kph.round(1)).to eq(20.3)
      expect(observation.barometric_pressure_pascals).to eq(100920)
      expect(observation.sea_level_pressure_pascals).to eq(100910)
      expect(observation.visibility_meters).to eq(16090)
      expect(observation.precipitation_1hr_mm).to eq(1)
      expect(observation.precipitation_3hr_mm).to eq(2)
      expect(observation.precipitation_6hr_mm).to eq(10)
      expect(observation.heat_index_celcius.round(1)).to eq(16.8)
      expect(observation.wind_chill_celcius.round(1)).to eq(13.1)
    end

    it "raises an error if the NOAA API returns an error" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").to_return(status: 500)
      expect { USWeather::NoaaObservation.new("KCCR").fetch }.to raise_error(USWeather::HttpError)
    end

    it "returns nil if the NOAA API returns a 404" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").to_return(status: 404)
      expect(USWeather::NoaaObservation.new("KCCR").fetch).to be_nil
    end
  end
end

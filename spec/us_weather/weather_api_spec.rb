# frozen_string_literal: true

require_relative "../spec_helper"

describe USWeather::WeatherAPI do
  describe "latest_observation" do
    it "gets data from the NOAA API and returns an observation" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest")
        .with(headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"})
        .to_return(status: 200, body: File.read("spec/fixtures/KCCR.json"), headers: {"Content-Type" => "application/ld+json"})

      observation = USWeather::WeatherAPI.latest_observation("KCCR")
      expect(observation[:station_id]).to eq("KCCR")
      expect(observation[:observed_at]).to eq(Time.parse("2023-06-06T02:53:00+00:00"))
      expect(observation[:description]).to eq("Clear")
      expect(observation[:icon_code]).to eq("skc")
      expect(observation[:elevation_meters].round(1)).to eq(7.0)
      expect(observation[:temperature_celcius].round(1)).to eq(15.6)
      expect(observation[:dewpoint_celcius].round(1)).to eq(10.6)
      expect(observation[:relative_humidity].round(3)).to eq(0.721)
      expect(observation[:wind_direction_degrees]).to eq(280)
      expect(observation[:wind_speed_kph].round(1)).to eq(18.4)
      expect(observation[:wind_gust_kph].round(1)).to eq(20.3)
      expect(observation[:barometric_pressure_pascals]).to eq(100920)
      expect(observation[:sea_level_pressure_pascals]).to eq(100910)
      expect(observation[:visibility_meters]).to eq(16090)
      expect(observation[:max_temperature_last_24_hours_celcius]).to eq(18.1)
      expect(observation[:min_temperature_last_24_hours_celcius]).to eq(12.8)
      expect(observation[:precipitation_1hr_mm]).to eq(1)
      expect(observation[:precipitation_3hr_mm]).to eq(2)
      expect(observation[:precipitation_6hr_mm]).to eq(10)
      expect(observation[:heat_index_celcius].round(1)).to eq(16.8)
      expect(observation[:wind_chill_celcius].round(1)).to eq(13.1)
    end

    it "raises an error if the NOAA API returns an error" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").to_return(status: 500)
      expect { USWeather::WeatherAPI.latest_observation("KCCR") }.to raise_error(USWeather::HttpError)
    end

    it "returns nil if the NOAA API returns a 404" do
      stub_request(:get, "https://api.weather.gov/stations/KCCR/observations/latest").to_return(status: 404)
      expect(USWeather::WeatherAPI.latest_observation("KCCR")).to be_nil
    end
  end

  describe "each_station" do
    it "iterates over all stations with paginated requests to the API" do
      stub_request(:get, "https://api.weather.gov/stations")
        .with(query: {limit: 500}, headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"})
        .to_return(status: 200, body: File.read("spec/fixtures/stations_page_1.json"), headers: {"Content-Type" => "application/ld+json"})

      stub_request(:get, "https://api.weather.gov/stations")
        .with(query: {limit: 500, cursor: "page2"}, headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"})
        .to_return(status: 200, body: File.read("spec/fixtures/stations_page_2.json"), headers: {"Content-Type" => "application/ld+json"})

      stub_request(:get, "https://api.weather.gov/stations")
        .with(query: {limit: 500, cursor: "page3"}, headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"})
        .to_return(status: 200, body: File.read("spec/fixtures/stations_page_3.json"), headers: {"Content-Type" => "application/ld+json"})

      USWeather::WeatherAPI.each_station do |station|
        puts station.inspect
      end
    end
  end

  describe "each_forecast_zone" do
    it "iterates over all stations with paginated requests to the API" do
      stub_request(:get, "https://api.weather.gov/zones")
        .with(query: {type: "forecast", effective: "#{Time.now.utc.to_date.iso8601}T00:00:00Z"}, headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"})
        .to_return(status: 200, body: File.read("spec/fixtures/forecast_zones.json"), headers: {"Content-Type" => "application/ld+json"})

      %w[AKZ101 AKZ111 AKZ121 AKZ125].each do |zone_id|
        stub_request(:get, "https://api.weather.gov/zones/forecast/#{zone_id}")
          .with(headers: {"Accept" => "application/ld+json", "Accept-Encoding" => "gzip"})
          .to_return(status: 200, body: File.read("spec/fixtures/FLZ017_zone.json"), headers: {"Content-Type" => "application/ld+json"})
      end

      USWeather::WeatherAPI.each_forecast_zone do |zone|
        puts zone.inspect
      end
    end
  end
end

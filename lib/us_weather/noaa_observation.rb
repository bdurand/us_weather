# frozen_string_literal: true

module USWeather
  class NoaaObservation
    BASE_URI = URI("https://api.weather.gov/").freeze

    attr_reader :station_id

    def initialize(station_id)
      @station_id = station_id
    end

    def fetch
      doc = fetch_observation
      return nil unless doc

      observation = WeatherObservation.new(icao_id: @station_id)
      observation.observed_at = Time.iso8601(doc["timestamp"])
      observation.description = doc["textDescription"]
      observation.icon_code = icon_code(doc["icon"])
      observation.temperature_celcius = doc.dig("temperature", "value")&.round(2)
      observation.dewpoint_celcius = doc.dig("dewpoint", "value")&.round(2)
      humidity = doc.dig("relativeHumidity", "value")&.round(4)
      observation.relative_humidity = humidity / 100 if humidity
      observation.wind_direction_degrees = doc.dig("windDirection", "value")
      observation.wind_speed_kph = doc.dig("windSpeed", "value")&.round(2)
      observation.wind_gust_kph = doc.dig("windGust", "value")&.round(2)
      observation.barometric_pressure_pascals = doc.dig("barometricPressure", "value")
      observation.sea_level_pressure_pascals = doc.dig("seaLevelPressure", "value")
      observation.visibility_meters = doc.dig("visibility", "value")
      observation.precipitation_1hr_mm = doc.dig("precipitationLastHour", "value")
      observation.precipitation_3hr_mm = doc.dig("precipitationLast3Hours", "value")
      observation.precipitation_6hr_mm = doc.dig("precipitationLast6Hours", "value")
      observation.heat_index_celcius = doc.dig("heatIndex", "value")&.round(2)
      observation.wind_chill_celcius = doc.dig("windChill", "value")&.round(2)

      observation
    end

    private

    def fetch_observation
      body = nil

      Net::HTTP.start(BASE_URI.host, BASE_URI.port, use_ssl: true, open_timeout: USWeather.open_timeout, read_timeout: USWeather.read_timeout) do |http|
        response = http.request(request)
        if response.is_a?(Net::HTTPSuccess)
          body = response.body
          if response["Content-Encoding"] == "gzip"
            body = Zlib::GzipReader.new(StringIO.new(body)).read
          end
        elsif response.is_a?(Net::HTTPNotFound)
          return nil
        else
          raise HttpError.new("#{response.code} #{response.message}")
        end
      end

      JSON.parse(body)
    end

    def request
      path = "/stations/#{station_id}/observations/latest"
      request = Net::HTTP::Get.new(path)
      request["Accept"] = "application/ld+json"
      request["Accept-Encoding"] = "gzip"
      request["User-Agent"] = USWeather.user_agent
      request
    end

    def icon_code(icon_url)
      return nil unless icon_url
      URI(icon_url).path.split("/").last
    end
  end
end

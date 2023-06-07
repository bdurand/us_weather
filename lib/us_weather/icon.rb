# frozen_string_literal: true

module USWeather
  class Icon
    ICONS = {
      skc: {
        description: "Fair/clear",
        day: "clear-day",
        night: "clear-night"
      },
      few: {
        description: "A few clouds",
        day: "partly-cloudy-day",
        night: "partly-cloudy-night"
      },
      sct: {
        description: "Partly cloudy",
        day: "partly-cloudy-day",
        night: "partly-cloudy-night"
      },
      bkn: {
        description: "Mostly cloudy"
        day: "cloudy",
        night: "cloudy"
      },
      ovc: {
        description: "Overcast",
        day: "overcast-day",
        night: "overcast-night"
      },
      wind_skc: {
        description: "Fair/clear and windy",
        day: "wind",
        night: "wind"
      },
      wind_few: {
        description: "A few clouds and windy",
        day: "wind",
        night: "wind"
      },
      wind_sct: {
        description: "Partly cloudy and windy",
        day: "wind",
        night: "wind"
      },
      wind_bkn: {
        description: "Mostly cloudy and windy",
        day: "wind",
        night: "wind"
      },
      wind_ovc: {
        description: "Overcast and windy",
        day: "wind",
        night: "wind"
      },
      snow: {
        description: "Snow",
        day: "snow",
        night: "snow"
      },
      rain_snow: {
        description: "Rain/snow",
        day: "snow",
        night: "snow"
      },
      rain_sleet: {
        description: "Rain/sleet",
        day: "sleet",
        night: "sleet"
      },
      snow_sleet: {
        description: "Snow/sleet"
        day: "snow",
        night: "snow"
      },
      fzra: {
        description: "Freezing rain",
        day: "sleet",
        night: "sleet"
      },
      rain_fzra: {
        description: "Rain/freezing rain",
        day: "sleet",
        night: "sleet"
      },
      snow_fzra: {
        description: "Freezing rain/snow",
        day: "sleet",
        night: "sleet"
      },
      sleet: {
        description: "Sleet",
        day: "sleet",
        night: "sleet"
      },
      rain: {
        description: "Rain",
        day: "rain",
        night: "rain"
      },
      rain_showers: {
        description: "Rain showers (high cloud cover)",
        day: "rain",
        night: "rain"
      },
      rain_showers_hi: {
        description: "Rain showers (low cloud cover)",
        day: "rain",
        night: "rain"
      },
      tsra: {
        description: "Thunderstorm (high cloud cover)",
        day: "thunderstorms",
        night: "thunderstorms"
      },
      tsra_sct: {
        description: "Thunderstorm (medium cloud cover)",
        day: "thunderstorms",
        night: "thunderstorms"
      },
      tsra_hi: {
        description: "Thunderstorm (low cloud cover)",
        day: "thunderstorms",
        night: "thunderstorms"
      },
      tornado: {
        description: "Tornado",
        day: "tornado",
        night: "tornado"
      },
      hurricane: {
        description: "Hurricane conditions",
        day: "hurricane",
        night: "hurricane"
      },
      tropical_storm: {
        description: "Tropical storm conditions",
        day: "hurricane",
        night: "hurricane"
      },
      dust: {
        description: "Dust",
        day: "dust-day",
        night: "dust-night"
      },
      smoke: {
        description: "Smoke",
        day: "smoke",
        night: "smoke"
      },
      haze: {
        description: "Haze",
        day: "haze-day",
        night: "haze-night"
      },
      hot: {
        description: "Hot",
        day: "thermometer-warmer",
        night: "thermometer-warmer"
      },
      cold: {
        description: "Cold",
        day: "thermometer-colder",
        night: "thermometer-colder"
      },
      blizzard: {
        description: "Blizzard",
        day: "thunderstorms-snow",
        night: "thunderstorms-snow"
      },
      fog: {
        description: "Fog/mist",
        day: "fog-day",
        night: "fog-night"
      }
    }.freeze
  end
end

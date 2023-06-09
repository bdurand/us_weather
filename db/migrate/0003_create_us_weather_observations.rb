# frozen_string_literal: true

class CreateUsWeatherObservations < ActiveRecord::Migration[5.0]
  def up
    create_table :us_weather_observations do |t|
      t.string :station_id, null: false, limit: 12
      t.datetime :observed_at, null: false
      t.string :description, null: true, limit: 100
      t.string :icon_code, null: true, limit: 20
      t.float :temperature_celcius, null: true
      t.float :dewpoint_celcius, null: true
      t.float :relative_humidity, null: true
      t.float :wind_speed_kph, null: true
      t.float :wind_gust_kph, null: true
      t.integer :wind_direction_degrees, null: true, limit: 2
      t.integer :barometric_pressure_pascals, null: true, limit: 4
      t.float :elevation_meters, null: true
      t.float :heat_index_celcius, null: true
      t.float :wind_chill_celcius, null: true
      t.integer :visibility_meters, null: true, limit: 4
    end

    add_index :us_weather_observations, [:station_id, :observed_at], unique: true
  end

  def down
    drop_table :us_weather_observations
  end
end

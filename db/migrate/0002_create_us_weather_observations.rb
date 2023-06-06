# frozen_string_literal: true

class CreateUsWeatherObservations < ActiveRecord::Migration[5.0]
  def up
    create_table :us_weather_observations do |t|
      t.string :icao_id, null: false, limit: 5
      t.datetime :observed_at, null: false
      t.string :description, null: false, limit: 100
      t.string :icon_code, null: true, limit: 20
      t.float :temperature_celcius, null: true
      t.float :dewpoint_celcius, null: true
      t.float :relative_humidity, null: true
      t.float :wind_speed_kph, null: true
      t.float :wind_gust_kph, null: true
      t.integer :wind_direction_degrees, null: true, limit: 2
      t.integer :barometric_pressure_pascals, null: true, limit: 4
      t.integer :sea_level_pressure_pascals, null: true, limit: 4
      t.float :heat_index_celcius, null: true
      t.float :wind_chill_celcius, null: true
      t.integer :precipitation_1hr_mm, null: true, limit: 2
      t.integer :precipitation_3hr_mm, null: true, limit: 2
      t.integer :precipitation_6hr_mm, null: true, limit: 2
      t.integer :visibility_meters, null: true, limit: 4
      t.datetime :created_at, null: false
    end

    add_index :us_weather_observations, [:icao_id, :observed_at], unique: true
  end

  def down
    drop_table :us_weather_observations
  end
end

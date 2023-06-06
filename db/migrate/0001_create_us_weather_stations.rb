# frozen_string_literal: true

class CreateUsWeatherStations < ActiveRecord::Migration[5.0]
  def up
    create_table :us_weather_stations, id: false do |t|
      t.string :icao_id, null: false, limit: 5, primary_key: true
      t.string :name, null: false, limit: 100
      t.string :state, null: false, limit: 2
      t.float :lat, null: false
      t.float :lng, null: false
      t.float :elevation_meters, null: false
      t.integer :wban_id, null: true, limit: 4, index: {unique: true}
      t.integer :wmo_id, null: true, limit: 4, index: {unique: true}
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :us_weather_stations, [:lng, :lat]
  end

  def down
    drop_table :us_weather_stations
  end
end

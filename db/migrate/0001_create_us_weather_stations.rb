# frozen_string_literal: true

class CreateUsWeatherStations < ActiveRecord::Migration[5.0]
  def up
    create_table :us_weather_stations, id: false do |t|
      t.string :id, null: false, limit: 12, primary_key: true
      t.string :name, null: false, limit: 100
      t.boolean :active, null: false, default: true
      t.string :county_id, null: true, limit: 6
      t.string :forecast_zone_id, null: true, limit: 6
      t.string :fire_zone_id, null: true, limit: 6
      t.string :county_fips_code, null: true, limit: 5
      t.string :state_code, null: true, limit: 2
      t.string :time_zone, null: true, limit: 30
      t.geography "lnglat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}, index: {using: :gist}
      t.timestamps
    end
  end

  def down
    drop_table :us_weather_stations
  end
end

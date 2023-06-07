# frozen_string_literal: true

class CreateUsWeatherZones < ActiveRecord::Migration[5.0]
  def up
    create_table :us_weather_zones, id: false do |t|
      t.string :id, null: false, limit: 12, primary_key: true
      t.string :name, null: false, limit: 200
      t.boolean :active, null: false, default: true
      t.geography "area", null: false, limit: {srid: 4326, type: "geometry", geographic: true}, index: {using: :gist}
      t.timestamps
    end
  end

  def down
    drop_table :us_weather_zones
  end
end

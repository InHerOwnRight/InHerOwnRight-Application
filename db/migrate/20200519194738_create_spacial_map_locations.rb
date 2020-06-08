class CreateSpacialMapLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :spacial_map_locations do |t|
      t.integer :dc_terms_spacial_id
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :location_rpt
      t.string :geojson_ssim
      t.string :placename
      t.datetime :geocode_attempt
      t.datetime :verified, default: DateTime.now

      t.timestamps
    end
  end
end

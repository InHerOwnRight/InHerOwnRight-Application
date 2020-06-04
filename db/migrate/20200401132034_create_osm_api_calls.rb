class CreateOsmApiCalls < ActiveRecord::Migration[5.0]
  def change
    create_table :osm_api_calls do |t|
      t.string :placename, index: true
      t.string :sanitized_placename, index: true
      t.text :request
      t.text :response
      t.timestamps
    end
  end
end

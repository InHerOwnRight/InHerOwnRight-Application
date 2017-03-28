class CreateDcFormats < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_formats do |t|
      t.integer :record_id
      t.string :format
      t.timestamps
    end
  end
end

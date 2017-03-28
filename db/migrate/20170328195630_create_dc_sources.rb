class CreateDcSources < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_sources do |t|
      t.integer :record_id
      t.string :source
      t.timestamps
    end
  end
end

class CreateDcIdentifiers < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_identifiers do |t|
      t.integer :record_id
      t.string :identifier
      t.timestamps
    end
  end
end

class CreatePacsclCollections < ActiveRecord::Migration[5.1]
  def change
    create_table :pacscl_collections do |t|
      t.integer :repository_id
      t.string :import_source
      t.string :detailed_name
      t.string :clean_name

      t.timestamps
    end
  end
end

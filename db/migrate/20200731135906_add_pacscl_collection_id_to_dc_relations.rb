class AddPacsclCollectionIdToDcRelations < ActiveRecord::Migration[5.1]
  def change
    add_column :dc_relations, :pacscl_collection_id, :integer
  end
end

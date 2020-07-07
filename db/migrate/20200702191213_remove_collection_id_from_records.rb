class RemoveCollectionIdFromRecords < ActiveRecord::Migration[5.1]
  def change
    remove_column :records, :collection_id
  end
end

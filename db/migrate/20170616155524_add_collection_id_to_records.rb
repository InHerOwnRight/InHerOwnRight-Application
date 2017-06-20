class AddCollectionIdToRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :records, :collection_id, :integer
    add_column :raw_records, :record_type, :string
  end
end

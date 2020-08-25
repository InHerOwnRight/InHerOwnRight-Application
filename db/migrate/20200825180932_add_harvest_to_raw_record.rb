class AddHarvestToRawRecord < ActiveRecord::Migration[5.1]
  def change
    add_column :raw_records, :harvest_id, :integer
  end
end

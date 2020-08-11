class CreateCsvHarvestRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :csv_harvest_records do |t|
      t.integer :csv_harvest_id
      t.integer :record_id
    end
  end
end

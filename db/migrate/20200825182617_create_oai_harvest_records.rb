class CreateOaiHarvestRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :oai_harvest_records do |t|
      t.integer :oai_harvest_id
      t.integer :record_id
    end
  end
end

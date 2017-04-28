class CreateRecordDcTypeTables < ActiveRecord::Migration[5.0]
  def change
    create_table :record_dc_type_tables do |t|
      t.integer :record_id
      t.integer :dc_type_id
    end
  end
end

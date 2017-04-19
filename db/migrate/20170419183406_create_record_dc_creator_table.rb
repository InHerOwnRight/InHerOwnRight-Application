class CreateRecordDcCreatorTable < ActiveRecord::Migration[5.0]
  def change
    create_table :record_dc_creator_tables do |t|
      t.integer :record_id
      t.integer :dc_creator_id
    end
  end
end

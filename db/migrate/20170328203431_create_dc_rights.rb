class CreateDcRights < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_rights do |t|
      t.integer :record_id
      t.string :rights
      t.timestamps
    end
  end
end

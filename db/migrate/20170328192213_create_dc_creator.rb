class CreateDcCreator < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_creators do |t|
      t.integer :record_id
      t.string :creator
      t.timestamps
    end
  end
end

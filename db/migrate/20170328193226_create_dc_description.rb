class CreateDcDescription < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_descriptions do |t|
      t.integer :record_id
      t.text :description
      t.timestamps
    end
  end
end

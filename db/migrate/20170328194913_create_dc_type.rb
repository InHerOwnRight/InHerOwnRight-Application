class CreateDcType < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_types do |t|
      t.integer :record_id
      t.string :type
      t.timestamps
    end
  end
end

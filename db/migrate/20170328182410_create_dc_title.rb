class CreateDcTitle < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_titles do |t|
      t.integer :record_id
      t.string :title
      t.timestamps
    end
  end
end

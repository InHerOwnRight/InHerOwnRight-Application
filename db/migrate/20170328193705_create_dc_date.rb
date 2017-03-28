class CreateDcDate < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_dates do |t|
      t.integer :record_id
      t.string :date
      t.timestamps
    end
  end
end

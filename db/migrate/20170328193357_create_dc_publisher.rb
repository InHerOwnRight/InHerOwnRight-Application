class CreateDcPublisher < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_publishers do |t|
      t.integer :record_id
      t.string :publisher
      t.timestamps
    end
  end
end

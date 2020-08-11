class CreateCsvHarvest < ActiveRecord::Migration[5.1]
  def change
    create_table :csv_harvests do |t|
      t.integer :status, default: 0

      t.timestamps
    end
  end
end

class AddErrorToCsvHarvest < ActiveRecord::Migration[5.1]
  def change
    change_table :csv_harvests do |t|
      t.string :error
    end
  end
end

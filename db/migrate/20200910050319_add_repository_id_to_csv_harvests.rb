class AddRepositoryIdToCsvHarvests < ActiveRecord::Migration[5.2]
  def change
    change_table :csv_harvests do |t|
      t.integer :repository_id
    end
  end
end

class AddErrorToOaiHarvest < ActiveRecord::Migration[5.2]
  def change
    change_table :oai_harvests do |t|
      t.string :error
    end
  end
end

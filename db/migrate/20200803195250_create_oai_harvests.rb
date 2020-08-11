class CreateOaiHarvests < ActiveRecord::Migration[5.1]
  def change
    create_table :oai_harvests do |t|
      t.integer :repository_id
      t.integer :status, default: 0

      t.timestamps
    end
  end
end

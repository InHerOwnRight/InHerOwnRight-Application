class CreateDcContributor < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_contributors do |t|
      t.integer :record_id
      t.string :contributor
      t.timestamps
    end
  end
end

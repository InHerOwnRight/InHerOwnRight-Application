class CreateDcRelation < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_relations do |t|
      t.integer :record_id
      t.string :relation
      t.timestamps
    end
  end
end

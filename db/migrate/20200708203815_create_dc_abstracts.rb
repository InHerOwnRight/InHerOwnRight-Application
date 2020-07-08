class CreateDcAbstracts < ActiveRecord::Migration[5.1]
  def change
    create_table :dc_abstracts do |t|
      t.integer :record_id
      t.text :abstract

      t.timestamps
    end
  end
end

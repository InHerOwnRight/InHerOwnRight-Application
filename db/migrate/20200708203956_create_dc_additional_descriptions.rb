class CreateDcAdditionalDescriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :dc_additional_descriptions do |t|
      t.integer :record_id
      t.text :additional_description

      t.timestamps
    end
  end
end

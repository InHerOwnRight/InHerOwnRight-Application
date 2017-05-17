class CreateDcTermsExtent < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_terms_extents do |t|
      t.integer :record_id
      t.string :extent
      t.timestamps
    end
  end
end

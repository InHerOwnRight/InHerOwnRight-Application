class CreateDcTermsSpacial < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_terms_spacials do |t|
      t.integer :record_id
      t.string :spacial
      t.timestamps
    end
  end
end

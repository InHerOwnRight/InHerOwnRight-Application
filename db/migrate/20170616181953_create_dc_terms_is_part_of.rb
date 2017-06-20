class CreateDcTermsIsPartOf < ActiveRecord::Migration[5.0]
  def change
    create_table :dc_terms_is_part_ofs do |t|
      t.integer :record_id
      t.string :is_part_of
      t.timestamps
    end
  end
end

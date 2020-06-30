class AddPacsclCollectionIdToDcTermsIsPartOf < ActiveRecord::Migration[5.1]
  def change
    add_column :dc_terms_is_part_ofs, :pacscl_collection_id, :integer
  end
end

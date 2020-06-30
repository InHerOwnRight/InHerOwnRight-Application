class PacsclCollection < ActiveRecord::Base
  belongs_to :repository
  has_many :dc_terms_is_part_ofs
  has_many :records, through: :dc_terms_is_part_ofs
  after_create :update_associations_and_reindex_after_create
  after_save :update_associations_and_reindex, if: :saved_change_to_detailed_name
  around_destroy :update_associations_and_reindex_after_destroy

  private

  def update_associations_and_reindex_after_create
    dc_terms_is_part_of_collection = DcTermsIsPartOf.where(is_part_of: detailed_name)
    dc_terms_is_part_of_collection.each do |dc_terms_is_part_of|
      dc_terms_is_part_of.pacscl_collection_id = id
      dc_terms_is_part_of.save
    end
    Sunspot.index!(records)
  end

  def update_associations_and_reindex
    dc_terms_is_part_of_collection = dc_terms_is_part_ofs
    dc_terms_is_part_of_collection.each do |dc_terms_is_part_of|
      dc_terms_is_part_of.pacscl_collection_id = nil
      dc_terms_is_part_of.save
    end
    Sunspot.index!(records)
  end

  def update_associations_and_reindex_after_destroy
    dc_terms_is_part_ofs.each do |dc_terms_is_part_of|
      dc_terms_is_part_of.pacscl_collection_id = nil
      dc_terms_is_part_of.save
    end
    record_collection = records
    yield
    Sunspot.index!(record_collection)
  end
end

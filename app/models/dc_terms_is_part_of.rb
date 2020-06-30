class DcTermsIsPartOf < ActiveRecord::Base
  belongs_to :record
  belongs_to :pacscl_collection, optional: true
  after_create :check_pacscl_collection
  after_save :check_pacscl_collection, if: :saved_change_to_is_part_of

  private

  def check_pacscl_collection
    matching_pacscl_collection = PacsclCollection.find_by_detailed_name(is_part_of)
    if matching_pacscl_collection
      self.pacscl_collection_id = matching_pacscl_collection.id
      save
    end
  end
end

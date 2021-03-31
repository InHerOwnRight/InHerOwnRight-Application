class DcRelation < ActiveRecord::Base
  belongs_to :record
  belongs_to :pacscl_collection, optional: true
  after_create :check_pacscl_collection
  after_save :check_pacscl_collection, if: :saved_change_to_relation?

  private

  def check_pacscl_collection
    if !self.relation.nil?
      begin
        relation = self.relation.split(",").first.strip if self.record.repository.islandora?
        matching_pacscl_collection = PacsclCollection.all.find { |c| c.detailed_name.downcase.include?(relation.downcase) }
        if matching_pacscl_collection
          self.pacscl_collection_id = matching_pacscl_collection.id
          save
        end
      rescue
      end
    end
  end
end

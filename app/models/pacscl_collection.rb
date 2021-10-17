class PacsclCollection < ActiveRecord::Base
  belongs_to :repository
  has_many :dc_terms_is_part_ofs
  has_many :dc_relations
  after_save :update_associations_and_reindex, if: :saved_change_to_detailed_name?
  around_destroy :update_associations_and_reindex_after_destroy

  def associated_records
    dc_terms_is_part_of_records = dc_terms_is_part_ofs.map { |dtipo| dtipo.record }
    dc_relation_records = dc_relations.map { |dr| dr.record }

    combined_records = dc_terms_is_part_of_records + dc_relation_records
    combined_records.compact.uniq
  end

  private

  def update_associations_and_reindex
    dc_terms_is_part_of_collection = dc_terms_is_part_ofs + DcTermsIsPartOf.where(is_part_of: detailed_name)
    dc_terms_is_part_of_collection.uniq!

    dc_relations_collection = dc_relations + DcRelation.where(relation: detailed_name)
    dc_relations_collection.uniq!

    dtipo_record_collection = dc_terms_is_part_of_collection.map{ |dtipo| dtipo.record }
    dr_record_collection = dc_relations_collection.map{ |drc| drc.record }

    combined_record_collection = dtipo_record_collection + dr_record_collection
    combined_record_collection.uniq!

    dc_terms_is_part_of_collection.each do |dc_terms_is_part_of|
      if dc_terms_is_part_of.is_part_of == detailed_name
        dc_terms_is_part_of.pacscl_collection_id = id
      else
        dc_terms_is_part_of.pacscl_collection_id = nil
      end
      dc_terms_is_part_of.save
    end

    dc_relations_collection.each do |dc_relation|
      if dc_relation.relation == detailed_name
        dc_relation.pacscl_collection_id = id
      else
        dc_relation.pacscl_collection_id = nil
      end
      dc_relation.save
    end

    # If this fails, run rake clear:orphans
    Sunspot.index!(combined_record_collection)
  end

  def update_associations_and_reindex_after_destroy
    record_collection = associated_records

    dc_terms_is_part_ofs.each do |dc_terms_is_part_of|
      dc_terms_is_part_of.pacscl_collection_id = nil
      dc_terms_is_part_of.save
    end

    dc_relations.each do |dc_relation|
      dc_relation.pacscl_collection_id = nil
      dc_relation.save
    end

    yield

    Sunspot.index!(record_collection)
  end
end

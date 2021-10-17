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

  def easy_match_detailed_name
    self.class.easy_match_detailed_name(detailed_name)
  end

  def self.easy_match_detailed_name(detailed_name)
    # Many detailed names start with the thing we care about, and end in some metadata that we don't
    regexes = []
    regexes << /(.*?)\s*--\s*https?:\/\/.*/i
    regexes << /(.*?)\s+\([A-Z0-9.-]+\)/
    regexes << /(.*?), [A-Z]+-[A-Z0-9]+-[0-9]+/
    regexes << /(.*?), 19\d{2}-19\d{2}--[A-Z]+-[0-9]+/
    regexes << /(.*?), 19\d{2}-19\d{2}/
    # These 2 are for Temple (Caroline Katzenstein Collection)
    regexes << /(.*?), [A-Za-z]{2} ?\.[0-9]{4}/
    regexes << /(.*?)\s*\([A-Za-z]{2} ?\.[0-9]{4}\)/
    
    result = regexes.inject(detailed_name) do |previous_result, regex|
      if match = regex.match(previous_result)
        match[1]
      else
        previous_result
      end
    end
  end

  # This will help us explore the data looking for unmatched records
  def self.match_candidates(like_match_term)
    {dc_relations: dc_relation_match_candidates(like_match_term, true),
     dc_terms_is_part_of: dc_terms_is_part_of_match_candidates(like_match_term, true)
    }
  end

  def self.dc_relation_match_candidates(like_match_term, stats_only=false)
    if stats_only
      DcRelation.where("relation ILIKE ?", like_match_term).select("relation, COUNT(*) AS num").group(:relation).map{|r| [r.relation, r.num]}
    else
      DcRelation.where("relation ILIKE ?", like_match_term)
    end
  end

  def self.dc_terms_is_part_of_match_candidates(like_match_terms, stats_only=false)
    if stats_only
      DcTermsIsPartOf.where("is_part_of LIKE ? ", like_match_terms).select("is_part_of, COUNT(*) AS num").group(:is_part_of).map{|r| [r.is_part_of, r.num]}
    else
      DcTermsIsPartOf.where("is_part_of LIKE ? ", like_match_terms)
    end
  end

  def collection_record
    @collection_record ||= DcTitle.where("LOWER(title) = lower(?)", detailed_name).first.try(:record)
  end

  private

  def update_associations_and_reindex_for_sharpless
    puts "Updating sharpless collections"
    raise "Can't assign Sharpless collection unless you're working on the Sharpless collection"  unless self.detailed_name == "Sharpless Family papers"
    sharpless_identifiers = DcIdentifier.where("identifier LIKE '%mc1111%'")
    records = sharpless_identifiers.map(&:record).compact
    records.each do |record|
      dc_relation = record.dc_relations.first
      dc_relation ||= record.dc_relations.create(relation: self.detailed_name)
      dc_relation.update_attributes(pacscl_collection_id: self.id)
    end

    Sunspot.index!(records)
  end

  def update_associations_and_reindex
    return update_associations_and_reindex_for_sharpless if self.detailed_name == "Sharpless Family papers"

    easy_name = easy_match_detailed_name

    dc_terms_is_part_of_collection = dc_terms_is_part_ofs + self.class.dc_terms_is_part_of_match_candidates("#{easy_name}%")
    dc_terms_is_part_of_collection.uniq!

    dc_relations_collection = dc_relations + self.class.dc_relation_match_candidates("#{easy_name}%")
    dc_relations_collection.uniq!

    dtipo_record_collection = dc_terms_is_part_of_collection.map{ |dtipo| dtipo.record }
    dr_record_collection = dc_relations_collection.map{ |drc| drc.record }

    combined_record_collection = dtipo_record_collection + dr_record_collection
    combined_record_collection.uniq!

    dc_terms_is_part_of_collection.each do |dc_terms_is_part_of|
      if dc_terms_is_part_of.is_part_of.start_with?(easy_name)
        # 100% of them are this case
        dc_terms_is_part_of.pacscl_collection_id = id
      else
        dc_terms_is_part_of.pacscl_collection_id = nil
      end
      dc_terms_is_part_of.save
    end

    dc_relations_collection.each do |dc_relation|
      if dc_relation.relation.start_with?(easy_name)
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

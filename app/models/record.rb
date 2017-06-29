
class Record < ActiveRecord::Base
  belongs_to :raw_record
  delegate :repository, to: :raw_record, allow_nil: true
  has_many :dc_contributors, dependent: :destroy
  has_many :dc_coverages, dependent: :destroy
  has_many :record_dc_creator_tables, dependent: :destroy
  has_many :dc_creators, through: :record_dc_creator_tables
  has_many :record_dc_type_tables, dependent: :destroy
  has_many :dc_types, through: :record_dc_type_tables
  has_many :dc_dates, dependent: :destroy
  has_many :dc_descriptions, dependent: :destroy
  has_many :dc_formats, dependent: :destroy
  has_many :dc_identifiers, dependent: :destroy
  has_many :dc_languages, dependent: :destroy
  has_many :dc_publishers, dependent: :destroy
  has_many :dc_relations, dependent: :destroy
  has_many :dc_rights, dependent: :destroy
  has_many :dc_sources, dependent: :destroy
  has_many :dc_subjects, dependent: :destroy
  has_many :dc_titles, dependent: :destroy
  has_many :dc_terms_extents, dependent: :destroy
  has_many :dc_terms_spacials, dependent: :destroy
  has_many :full_texts, dependent: :destroy
  has_many :dc_terms_is_part_ofs, dependent: :destroy

  scope :collection_for, -> (collection_name) { joins(:dc_titles).where('dc_titles.title = ?', collection_name) }
  scope :collections, -> { joins(:raw_record).where(raw_records: {record_type: 'collection'}) }
  scope :not_collections, -> { joins(:raw_record).where(raw_records: {record_type: nil}) }
  scope :for_repository, -> (repository) { joins(:raw_record).where(raw_records: {repository_id: repository.id} )}
  scope :records_for_collection, -> (record_id) { where(collection_id: record_id) }

  def is_collection?
    raw_record.record_type == "collection"
  end

  def repository_id
    repository.id
  end

  def is_collection_id
    if is_collection?
      id
    else
      nil
    end
  end

  searchable do
    text :oai_identifier

    text :contributor do
      dc_contributors.map(&:contributor)
    end

    text :coverage do
      dc_coverages.map(&:coverage)
    end

    text :creator do
      dc_creators.map(&:creator)
    end

    integer :dc_creator_ids, references: DcCreator, multiple: true

    integer :repository_id, references: Repository

    integer :dc_type_ids, references: DcType, multiple: true

    date :pub_date, references: DcDate, multiple: true do
      dc_dates.original_creation_date.map(&:date)
    end

    text :description do
      dc_descriptions.map(&:description)
    end

    text :format do
      dc_formats.map(&:format)
    end

    text :language do
      dc_languages.map(&:language)
    end

    text :publisher do
      dc_publishers.map(&:publisher)
    end

    text :relation do
      dc_relations.map(&:relation)
    end

    text :rights do
      dc_rights.map(&:rights)
    end

    text :source do
      dc_sources.map(&:source)
    end

    text :subject do
      dc_subjects.map(&:subject)
    end

    text :title do
      dc_titles.map(&:title)
    end

    text :type do
      dc_types.map(&:type)
    end
  end

  searchable :if => proc { |record| !record.collection_id.nil? } do
    integer :collection_id, references: Record, multiple: true
  end

  searchable :if => proc { |record| record.is_collection? } do
    integer :is_collection_id, references: Record
  end #searchable

########################## Record and record part creation ################################

  def create_dc_creator(node, record)
    if DcCreator.find_by_creator(node.text).blank?
      dc_creator = DcCreator.new(creator: node.text)
      dc_creator.save
      record_dc_creator = RecordDcCreatorTable.new(dc_creator_id: dc_creator.id, record_id: record.id)
      record_dc_creator.save
    else
      dc_creator = DcCreator.find_by_creator(node.text)
      record = self
      record_dc_creator = RecordDcCreatorTable.new(dc_creator_id: dc_creator.id, record_id: record.id)
      record_dc_creator.save
    end
  end

  def create_dc_type(node, record)
    if DcType.find_by_type(node.text).blank?
      dc_type = DcType.new(type: node.text)
      dc_type.save
      record_dc_type = RecordDcTypeTable.new(dc_type_id: dc_type.id, record_id: record.id)
      record_dc_type.save
    else
      dc_type = DcType.find_by_type(node.text)
      record = self
      record_dc_type = RecordDcTypeTable.new(dc_type_id: dc_type.id, record_id: record.id)
      record_dc_type.save
    end
  end

  def create_dc_date(node, record)
    if node.text =~ /^\d{4}\-\d{4}$/
      date_range_points = node.text.split("-")
      year_range = date_range_points[0].to_i..date_range_points[1].to_i
      year_range.each_with_index do |year, index|
        year + index
        date = date = Date.new(year)
        dc_date = DcDate.new(record_id: record.id, date: date, unprocessed_date: node.text)
        dc_date.save
        index += 1
      end
    elsif node.text =~ /^\d{4}$/
      date = Date.new(node.text.to_i)
      dc_date = DcDate.new(record_id: record.id, date: date, unprocessed_date: node.text)
      dc_date.save
    else
      begin
        Date.parse(node.text)
        dc_date = DcDate.new(record_id: record.id, date: node.text, unprocessed_date: node.text)
        dc_date.save
      rescue
        dc_date = DcDate.new(record_id: record.id, unprocessed_date: node.text)
        dc_date.save
      end
    end
  end

  def create_dc_terms_extent(node, record)
    dc_terms_extent = DcTermsExtent.new(extent: node.text)
    dc_terms_extent.record_id = record.id
    dc_terms_extent.save
  end

  def create_dc_terms_spacial(node, record)
    dc_terms_spacial = DcTermsSpacial.new(spacial: node.text)
    dc_terms_spacial.record_id = record.id
    dc_terms_spacial.save
  end

  def create_dc_terms_is_part_of(node, record)
    dc_terms_ipo = DcTermsIsPartOf.new(is_part_of: node.text)
    dc_terms_ipo.record_id = record.id
    dc_terms_ipo.save
  end

  def create_full_text(node, record)
    full_text = FullText.new(transcription: node.text)
    full_text.record_id = record.id
    full_text.save
  end

  def create_dc_identifier(node, record)
    if node.text =~ /;$/
      dc_identifier = DcIdentifier.new(identifier: node.text.split(";").first)
    elsif node.text =~ /^\s/
      dc_identifier = DcIdentifier.new(identifier: node.text.split(" ").last)
    else
      dc_identifier = DcIdentifier.new(identifier: node.text)
    end
    dc_identifier.record_id = record.id
    dc_identifier.save
  end

  def actual_model_name(node_name)
    if node_name == "rights"
      @part_model_name = "dc_right"
    elsif node_name == "created"
      @part_model_name = "dc_date"
    elsif node_name == "license"
      @part_model_name = "dc_right"
    else
      @part_model_name = "dc_#{node_name}"
    end
  end

  def create_dc_part(node_name, xml_doc, record)
    xml_doc.xpath("//#{node_name}").map do |node|

      if node_name == "creator"
        create_dc_creator(node, record)
      end

      if node_name == "identifier"
        create_dc_identifier(node, record)
      end

      if node_name == "type"
        create_dc_type(node, record)
      end

      if node_name == "date" || node_name == "created"
        create_dc_date(node, record)
      end

      if node_name == "extent"
        create_dc_terms_extent(node, record)
      end

      if node_name == "spacial"
        create_dc_terms_spacial(node, record)
      end

      if node_name == "isPartOf"
        create_dc_terms_is_part_of(node, record)
      end

      if node_name == "text"
        create_full_text(node, record)
      end

      if node_name == "license"
        node_name = "rights"
      end

      actual_model_name(node_name)

      modular_creators = ['dc_creator', 'dc_date', 'dc_type', 'dc_extent', 'dc_spacial', 'dc_text', 'dc_isPartOf', 'dc_identifier']
      if !modular_creators.include?(@part_model_name)
        dc_model = "#{@part_model_name.camelize}".constantize.new
        dc_model.record_id = record.id
        dc_model[node_name] = node.text
        dc_model.save
      end
    end
  end

########################## Oai API Endpoint ################################

  def to_oai_dc
    OaiDcConverter.new(self).to_xml
  end


end
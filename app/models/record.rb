
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

  def repository_id
    repository.id
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
  end #searchable

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
      year_range.each do |year|
        date = date = Date.new(year)
        dc_date = DcDate.new(record_id: record.id, date: date, unprocessed_date: node.text)
        dc_date.save
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

      if node_name == "type"
        create_dc_type(node, record)
      end

      if node_name == "date" || node_name == "created"
        create_dc_date(node, record)
      end

      if node_name == "extent"
        create_dc_terms_extent(node, record)
      end

      if node_name == "license"
        node_name = "rights"
      end

      actual_model_name(node_name)

      modular_creators = ['dc_creator', 'dc_date', 'dc_type', 'dc_extent']
      if !modular_creators.include?(@part_model_name)
        dc_model = "#{@part_model_name.camelize}".constantize.new
        dc_model.record_id = record.id
        dc_model[node_name] = node.text
        dc_model.save
      end
    end
  end

end
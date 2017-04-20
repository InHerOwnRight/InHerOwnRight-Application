
class Record < ActiveRecord::Base
  belongs_to :raw_record
  has_many :dc_contributors, dependent: :destroy
  has_many :dc_coverages, dependent: :destroy
  has_many :record_dc_creator_tables, dependent: :destroy
  has_many :dc_creators, through: :record_dc_creator_tables
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
  has_many :dc_types, dependent: :destroy

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
    # something :date do
    #   dc_date.scope_for_original_composition.map(&:date)
    # end

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

  def create_dc_date(node, record)
    begin
      Date.parse(node.text)
      dc_date = DcDate.new(record_id: record.id, date: node.text)
      dc_date.save
    rescue
      date = Date.new(node.text.to_i)
      dc_date = DcDate.new(record_id: record.id, date: date)
      dc_date.save
    end
  end

  def create_dc_part(node_name, xml_doc, dc_namespace, record)
    if xml_doc.xpath("//dc:#{node_name}", dc_namespace).any?
      xml_doc.xpath("//dc:#{node_name}", dc_namespace).map do |node|

        if node_name == "rights"
          model_name = "dc_right"
        else
          model_name = "dc_#{node_name}"
        end

        if node_name == "creator"
          create_dc_creator(node, record)
        end

        if node_name == "date"
          create_dc_date(node, record)
        end

        modular_creators = ['dc_creator', 'dc_date']
        if !modular_creators.include?(model_name)
          plural_model_name = model_name.pluralize
          dc_model = "#{model_name.camelize}".constantize.new
          dc_model.record_id = record.id
          dc_model[node_name] = node.text
          dc_model.save
        end
      end
    end
  end

end
class Record < ActiveRecord::Base
  belongs_to :raw_record
  has_many :dc_contributors, dependent: :destroy
  has_many :dc_coverages, dependent: :destroy
  has_many :dc_creators, dependent: :destroy
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

  def create_dc_part(node_name, xml_doc, dc_namespace, record)
    if xml_doc.xpath("//dc:#{node_name}", dc_namespace).any?
      xml_doc.xpath("//dc:#{node_name}", dc_namespace).map do |node|

        if node_name == "rights"
          model_name = "dc_right"
        else
          model_name = "dc_#{node_name}"
        end

        plural_model_name = model_name.pluralize

        dc_model = "#{model_name.camelize}".constantize.new
        dc_model.record_id = record.id
        dc_model[node_name] = node.text
        dc_model.save
      end
    end
  end

end
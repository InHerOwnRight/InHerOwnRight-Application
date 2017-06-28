require 'nokogiri'

class OaiDcConverter
  attr_accessor :doc

  def initialize(record)
    @doc = record
  end

  def record_parts(doc, part_name)
    column_name = part_name.split("_").last
    if !doc.send(part_name.pluralize).blank?
      doc.send(part_name.pluralize).map{ |part| part.send(column_name) }
    else
      []
    end
  end

  def dates
    if !doc.dc_dates.blank?
      if doc.dc_dates.map(&:unprocessed_date).any? =~ /^\d{4}\-\d{4}$/
        [doc.dc_dates.first.unprocessed_date]
      else
        doc.dc_dates.map(&:unprocessed_date)
      end
    else
      []
    end
  end

  def rights
    if !doc.dc_rights.blank?
      doc.dc_rights.map(&:rights)
    else
      []
    end
  end

  def is_part_ofs
    if !doc.dc_terms_is_part_ofs.blank?
      doc.dc_terms_is_part_ofs.map(&:is_part_of)
    else
      []
    end
  end

  def to_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml['oai_dc'].dc( 'xmlns:oai_dc'       => "http://www.openarchives.org/OAI/2.0/oai_dc/",
                        'xmlns:dc'           => "http://purl.org/dc/elements/1.1/",
                        'xmlns:dcterms'      => "http://purl.org/dc/terms/",
                        'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd}
                      ) do

        if !rights.blank?
          rights.map{ |right| xml['dc'].rights right }
        end

        if !dates.blank?
          dates.map{ |date| xml['dc'].date date }
        end

        part_names = ["dc_contributor", "dc_coverage", "dc_creator", "dc_description", "dc_format",
        "dc_identifier", "dc_language", "dc_publisher", "dc_relation", "dc_source", "dc_subject",
        "dc_title", "dc_type"]

        part_names.each do | part_name |
          if !record_parts(doc, part_name).blank?
            record_parts(doc, part_name).map do |part_text|
              node_name = part_name.split("_").last
              xml['dc'].send(node_name, part_text)
            end
          end
        end

        terms_names = ["dc_terms_extent", "dc_terms_spacial"]

        terms_names.each do | term_name |
          if !record_parts(doc, term_name).blank?
            record_parts(doc, term_name).map do |term_text|
              node_name = term_name.split("_").last
              xml['dcterms'].send(node_name, term_text)
            end
          end
        end

        if !is_part_ofs.blank?
          is_part_ofs.map{ |is_part_of| xml['dcterms'].send("isPartOf", is_part_of) }
        end

      end
    end
    builder.doc.root.to_xml
  end
end
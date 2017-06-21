namespace :create_records do
  desc "Create records and Dublin Core parts from raw records"

  task all: [:collections, :records] do
  end

  task collections: :environment do
    raw_records = RawRecord.where(record_type: "collection")
    raw_records.each do |raw_record|
      record = Record.new
      record.raw_record_id = raw_record.id
      record.oai_identifier = raw_record.oai_identifier
      xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
      xml_doc.remove_namespaces!
      if record.save
        node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "license", "identifier", "description", "contributor", "publisher", "extent", "source", "spacial", "text", "isPartOf"]
        node_names.each do | node_name |
          record.create_dc_part(node_name, xml_doc, record)
        end
      end
    end
  end

  def is_part_of_repsitories
    ["Bates | PAU", "HSP | QQR", "TLC | AOX", "Haverford | HVC"]
  end

  def relation_repositories
    ["Temple | TEU"]
  end

  task records: :environment do
    raw_records = RawRecord.where(record_type: nil)
    raw_records.each do |raw_record|
      if Record.where(oai_identifier: raw_record.oai_identifier).blank?
        record = Record.new
        record.raw_record_id = raw_record.id
        record.oai_identifier = raw_record.oai_identifier
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        xml_doc.remove_namespaces!

        if record.save
          node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "license", "identifier", "description", "contributor", "publisher", "extent", "source", "spacial", "text", "isPartOf"]
          node_names.each do | node_name |
            record.create_dc_part(node_name, xml_doc, record)
          end

          record.reload

          # Create collection relationship for records in CSVs
          if is_part_of_repsitories.include?(raw_record.repository.abbreviation)
            record.dc_terms_is_part_ofs.each do |tct_is_part_of|
              if Record.collection_for(tct_is_part_of.is_part_of).any?
                record.collection_id = Record.collection_for(tct_is_part_of.is_part_of).first.id
                record.save
              end
            end
          end

          if relation_repositories.include?(raw_record.repository.abbreviation)
            record.dc_relations.each do |dc_relation|
              if Record.collection_for(dc_relation.relation).any?
                record.collection_id = Record.collection_for(dc_relation.relation).first.id
                record.save
              end
            end
          end

          # Drexel records have only one collection, but the name is inconsistent
          if raw_record.repository.abbreviation == "DrexelMed | DXU"
            if record.dc_relations.map{|dc_relation| dc_relation.relation =~ /Alumnae Association/}.any?
              collection = Record.collection_for("Reports and Transactions of the Annual Meetings of the Alumnae Association of the Woman's Medical College of Pennsylvania").first
              record.collection_id = collection.id
              record.save
            end
          end

          # One record from Swarthmore. The XML in the response differs from the collection XML.
          if raw_record.repository.abbreviation == "Swarthmore Peace | QQR"
            record.collection_id = Record.find_by_oai_identifier("http://www.swarthmore.edu/library/friends/ead/Mott.xml")
            record.save
          end

        else
          puts "Record for #{raw_record.oai_identifier} not created. Duplicate?"
        end
      end
    end
  end

end

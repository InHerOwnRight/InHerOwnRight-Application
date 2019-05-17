namespace :create_records do
  desc "Create records and Dublin Core parts from raw records"

  task all: [:collections, :records, :create_enhanced_data] do
  end

  task collections: :environment do
    raw_records = RawRecord.where(record_type: "collection")
    raw_records.each do |raw_record|
      if Record.where(oai_identifier: raw_record.oai_identifier).blank?
        record = Record.new
        record.raw_record_id = raw_record.id
        record.oai_identifier = raw_record.oai_identifier
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        xml_doc.remove_namespaces!
        if record.save
          node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "licence", "identifier", "description", "contributor", "publisher", "extent", "source", "spacial", "text", "isPartOf", "coverage"]
          node_names.each do | node_name |
            record.create_dc_part(node_name, xml_doc, record)
          end
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
      if !raw_record.xml_metadata.blank?
        if Record.where(oai_identifier: raw_record.oai_identifier).blank?
          record = Record.new
          record.raw_record_id = raw_record.id
          record.oai_identifier = raw_record.oai_identifier
          xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
          xml_doc.remove_namespaces!

          if record.save
            node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "licence", "identifier", "description", "contributor", "publisher", "extent", "source", "spatial", "text", "isPartOf", "coverage", "spacial"]
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
                record.collection_id = collection.id if !collection.blank?
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

task create_enhanced_data: :environment do
  filepath = "lib/documents/csv/enhanced_metadata.csv"
  CSV.foreach(filepath, headers: true) do |row|
    if DcIdentifier.find_by_identifier(row[1])
      record = DcIdentifier.find_by_identifier(row[1]).record

      if !row[2].blank?
        subjects = row[2].split("|")
        stripped_subjects = subjects.map { |s| s.strip }
        stripped_subjects -= [""]
        stripped_subjects.each do |subj|
          if DcSubject.find_by_subject(subj).blank?
            dc_subject = DcSubject.new
            dc_subject.subject = subj
            dc_subject.save
            record_dc_subject = RecordDcSubjectTable.new(dc_subject_id: dc_subject.id, record_id: record.id)
            record_dc_subject.save
          else
            dc_subject = DcSubject.find_by_subject(subj)
            record_dc_subject = RecordDcSubjectTable.new(dc_subject_id: dc_subject.id, record_id: record.id)
            record_dc_subject.save
          end
        end
      end
      
      if !row[3].blank?
          dc_terms_spacial = DcTermsSpacial.new
          dc_terms_spacial.spacial = row[3]
          dc_terms_spacial.record_id = record.id
          dc_terms_spacial.save
        end

        if !row[4].blank?
          full_text = FullText.new
          full_text.transcription = row[4]
          full_text.record_id = record.id
          full_text.save
        end

      else
        puts "Didn't find #{row[1]}!!!"
      end
    end
  end

end

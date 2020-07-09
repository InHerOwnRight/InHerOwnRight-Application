namespace :create_records do
  desc "Create records and Dublin Core parts from raw records"

  task all: [:collections, :records, :create_enhanced_data] do
  end

  task collections: :environment do
    ImportRecordCollectionsHelper.create_records
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
        record = Record.find_or_initialize_by(oai_identifier: raw_record.oai_identifier)
        record.raw_record_id = raw_record.id
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        xml_doc.remove_namespaces!

        if record.save
          node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "licence", "identifier", "description", "contributor", "publisher", "extent", "source", "spatial", "text", "isPartOf", "coverage", "spacial"]
          node_names.each do | node_name |
            record.create_dc_part(node_name, xml_doc, record)
          end

          record.reload
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
            else
              dc_subject = DcSubject.find_by_subject(subj)
            end
            record_dc_subject = RecordDcSubjectTable.find_or_initialize_by(record_id: record.id)
            record_dc_subject.id = dc_subject.id,
            record_dc_subject.save
          end
        end

        if !row[3].blank?
          dc_terms_spacial = DcTermsSpacial.find_or_initialize_by(record_id: record.id)
          dc_terms_spacial.spacial = row[3]
          dc_terms_spacial.save
        end

        if !row[4].blank?
          full_text = FullText.find_or_initialize_by(record_id: record.id)
          full_text.transcription = row[4]
          full_text.save
        end

      else
        puts "Didn't find #{row[1]}!!!"
      end
    end
  end
end

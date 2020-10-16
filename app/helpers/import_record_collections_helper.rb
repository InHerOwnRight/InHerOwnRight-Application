require "csv"

module ImportRecordCollectionsHelper
  def self.save_file(file)
    file_path = "#{Rails.root}/uploads/record_collections/record_collections.csv"
    File.write(file_path, file.read.force_encoding("UTF-8"))
  end

  def self.initiate
    create_raw_records
    create_records
    index_records
  end

  def self.create_raw_records
    name_spaces = {
      "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
      "xmlns:dcterms" => "http://purl.org/dc/terms/",
      "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
    }
    existing_raw_record_collection_ids = RawRecord.where(record_type: "collection").pluck(:id)

    # create new raw record collections or update existing
    CSV.foreach("#{Rails.root}/uploads/record_collections/record_collections.csv", headers: true) do |row|
      institution_name = row[0].gsub('"', '')
      repository = Repository.find_by_name(institution_name)
      if repository
        raw_record = RawRecord.find_or_initialize_by(oai_identifier: row[7].gsub('"', ''))

        raw_record.record_type = "collection"
        raw_record.repository_id = repository.id
        raw_record.original_record_url = row[8].gsub('"', '') if !row[8].nil?

        builder = Nokogiri::XML::Builder.new { |xml|
          xml.metadata {
            xml.contributing_repository institution_name
            xml['oai_qdc'].qualifieddc(name_spaces) do
              xml['dc'].title row[2].gsub('"', '') if !row[2].blank?
              xml['dc'].creator row[3].gsub('"', '') if !row[3].blank?
              xml['dcterms'].created row[4].gsub('"', '') if !row[4].blank?
              xml['dcterms'].created row[5].gsub('"', '') if !row[5].blank?
              xml['dcterms'].extent row[6].gsub('"', '') if !row[6].blank?
              xml['dc'].identifier row[7].gsub('"', '') if !row[7].blank?
              if !row[8].nil? && (row[8].split(":").first == "http" || row[8].split(":").first == "https")
                xml['dc'].identifier row[8].gsub('"', '')
              elsif !row[8].nil?
                xml['dc'].hasFormat row[8].gsub('"', '')
              end
              xml['dc'].subject row[9].gsub('"', '') if !row[9].blank?
              xml['dc'].abstract row[10].gsub('"', '') if !row[10].blank?
              xml['dc'].additional_description row[11].gsub('"', '') if !row[11].blank?
              xml['dc'].research_interest row[12].gsub('"', '') if !row[12].blank?
            end
          }
        }
        raw_record.xml_metadata = builder.to_xml

        if raw_record.save
          existing_raw_record_collection_ids.delete(raw_record.id)
        end
      else
        raise "No repository found to match CSV data insitution name: #{institution_name}. ----- Stored Insitituion names: #{Repository.pluck(:name).join(", ")}"
      end
    end

    # delete any raw record collections and associated record collections no longer on csv
    if existing_raw_record_collection_ids.any?
      existing_raw_record_collection_ids.each do |existing_raw_record_collection_id|
        raw_record = RawRecord.find(existing_raw_record_collection_id)
        if raw_record.record
          record = raw_record.record
          record.destroy
          Sunspot.index!(record)
        end
        raw_record.destroy
      end
    end
  end

  def self.create_records
    raw_records = RawRecord.where(record_type: "collection")
    raw_records.each do |raw_record|
      record = Record.find_or_initialize_by(oai_identifier: raw_record.oai_identifier)
      record.raw_record_id = raw_record.id
      xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
      xml_doc.remove_namespaces!
      if record.save
        node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "created", "licence", "identifier", "description", "abstract", "additional_description", "research_interest", "contributor", "publisher", "extent", "source", "spacial", "text", "isPartOf", "coverage"]
        node_names.each do | node_name |
          record.create_dc_part(node_name, xml_doc, record)
        end
      end
    end
  end

  def self.index_records
    raw_records = RawRecord.where(record_type: "collection")
    raw_records.each do |raw_record|
      record = raw_record.record
      Sunspot.index!(record)
    end
  end
end

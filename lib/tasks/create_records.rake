namespace :create_records do
  desc "Create records and Dublin Core parts from raw records"

  task from_raw_records: :environment do
    raw_records = RawRecord.all
    raw_record = raw_records.first
    raw_records.each do |raw_record|
      if Record.where(oai_identifier: raw_record.oai_identifier).blank?
        record = Record.new
        record.raw_record_id = raw_record.id
        record.oai_identifier = raw_record.oai_identifier
        xml_doc = Nokogiri::XML.parse(raw_record.xml_metadata)
        dc_namespace = {"dc" => "http://purl.org/dc/elements/1.1/"}
        if record.save
          node_names = ["title", "date", "creator", "subject", "format", "type", "language", "rights", "relation", "identifier"]
          node_names.each do | node_name |
            record.create_dc_part(node_name, xml_doc, dc_namespace, record)
          end
        end
      else
        puts "Record for #{raw_record.oai_identifier} not created. Duplicate?"
      end
    end
  end
end
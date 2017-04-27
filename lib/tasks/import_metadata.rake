require 'oai'
namespace :import_metadata do
  desc "Import metadata raw_records from repositories"

  def import_from_oai_client(repository, repo_path, base_response_record_path, identifiers)
    client = OAI::Client.new repo_path, :headers => { "From" => "oai@example.com" }
    identifiers.map do |identifier|

      if RawRecord.find_by_oai_identifier(identifier).blank?
        response = client.get_record identifier: identifier
        response_record = response.record

        raw_record = RawRecord.new
        if !response_record.header.set_spec.first.text.blank?
          raw_record.set_spec = response_record.header.set_spec.first.text
          raw_record.original_record_url = "#{base_response_record_path}/#{raw_record.set_spec}/#{identifier.split('/').last}"
        end
        if !response_record.header.identifier.blank?
          raw_record.oai_identifier = response_record.header.identifier
        end
        if !response_record.header.datestamp.blank?
          raw_record.original_entry_date = response_record.header.datestamp
        end
        if !response_record.metadata.blank?
          raw_record.xml_metadata = response_record.metadata
        end

        raw_record.repository_id = repository.id

        if raw_record.save
          puts "Successfully saved #{raw_record.oai_identifier}"
        else
          puts "Something went wrong."
        end

      else
        puts "#{identifier} has already been imported"
      end
    end
  end

  task from_temple: :environment do
    repository = Repository.find_by_name("Temple University Libraries")
    repo_path = 'http://digital.library.temple.edu/oai/oai.php'
    base_response_record_path = 'http://digital.library.temple.edu/cdm/ref/collection/'

    identifiers = ['oai:digital.library.temple.edu:p15037coll19/1208', 'oai:digital.library.temple.edu:p15037coll19/1258', 'oai:digital.library.temple.edu:p15037coll19/1299']
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers)
  end

  require "csv"
  task from_bates: :environment do
    repository = Repository.find_by_name("Barbara Bates Center for the Study of the History of Nursing | University of Pennsylvania School of Nursing")
    NS = {
        "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
        "xmlns:oai_dc"  => "http://www.openarchives.org/OAI/2.0/oai_dc/",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dc"      => "http://purl.org/dc/elements/1.1/",
        "xmlns:xsi"     => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://worldcat.org/xmlschemas/qdc-1.0/ http://worldcat.org/xmlschemas/qdc/1.0/qdc-1.0.xsd http://purl.org/net/oclcterms http://worldcat.org/xmlschemas/oclcterms/1.4/oclcterms-1.4.xsd http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
    }
    CSV.foreach("lib/documents/csv/bates_center/BatesCenter.csv", headers: true) do |row|
      if RawRecord.find_by_oai_identifier(row[1]).blank?
        raw_record = RawRecord.new
        raw_record.repository_id = repository.id
        raw_record.original_record_url = "Local file: BatesCenter.csv"
        raw_record.oai_identifier = row[1]
        raw_record.original_entry_date = "2017-3-13" # hardcoded until we get a filenaming scheme

        builder = Nokogiri::XML::Builder.new { |xml|
          xml.metadata {
            xml.contributing_repository row[0]
            xml['oai_qdc'].qualifieddc(NS) do
              xml['dc'].identifier row[1]
              xml['dc'].title row[2]
              xml['dcterms'].created row[3]
              xml['dc'].creator row[4]
              xml['dcterms'].licence row[5]
              xml['dc'].type row[7]
              xml['dc'].language row[8]
              xml['dcterms'].extent row[11]
              xml['dc'].subject row[12]
              xml['dcterms'].spacial row[13]
              xml['dc'].description row[14]
              xml['dc'].publisher row[15]
              xml['dcterms'].isPartOf row[16]
              xml['dc'].format row[19]
            end
          }
        }
        raw_record.xml_metadata = builder.to_xml
        raw_record.save
      else
        puts "Raw record for OAI ID #{row[1]} already exists."
      end
    end
  end

end
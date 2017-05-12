require 'oai'
require "csv"

namespace :import_metadata do
  desc "Import metadata raw_records from repositories"

  task all: [:from_temple, :from_swarthmore, :from_drexel, :from_bates, :from_library_co, :from_haverford] do
  end

  def import_from_oai_client(repository, repo_path, base_response_record_path, identifiers, metadata_prefix)
    client = OAI::Client.new  repo_path, :headers => { "From" => "oai@example.com" }
    identifiers.map do |identifier|

      if RawRecord.find_by_oai_identifier(identifier).blank?
        response = client.get_record({identifier: identifier, metadata_prefix: metadata_prefix})
        response_record = response.record
        raw_record = RawRecord.new
        if !response_record.header.set_spec.first.text.blank?
          raw_record.set_spec = response_record.header.set_spec.first.text
          raw_record.original_record_url = "#{base_response_record_path}/#{raw_record.set_spec}/id/#{identifier.split('/').last}"
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
    identifiers = []
    set_specs = ['p15037coll19', 'p15037coll14']

    set_specs.map do |set|
      client = OAI::Client.new "http://digital.library.temple.edu/oai/oai.php", :headers => { "From" => "oai@example.com" }
      client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
        xml_metadata = Nokogiri::XML.parse(record.metadata.to_s)
        xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/").each do |relation_node|
          if relation_node.text.include?("In Her Own Right")
            identifiers.push(record.header.identifier)
          end
        end
      end
    end
    repository = Repository.find_by_name("Temple University Libraries")
    repo_path = 'http://digital.library.temple.edu/oai/oai.php'
    base_response_record_path = 'http://digital.library.temple.edu/cdm/ref/collection/'
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers, metadata_prefix)
  end

  task from_drexel: :environment do
    identifiers = []
    set_specs = ['lca_3']

    set_specs.map do |set|
      client = OAI::Client.new "https://idea.library.drexel.edu/oai/request", :headers => { "From" => "oai@example.com" }
      client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
        identifiers.push(record.header.identifier)
      end
    end

    repository = Repository.find_by_name("Drexel University College of Medicine Legacy Center")
    repo_path = "https://idea.library.drexel.edu/oai/request"
    base_response_record_path = "http://hdl.handle.net/1860/"
    metadata_prefix = "oai_dc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers, metadata_prefix)
  end

  task from_swarthmore: :environment do
    repository = Repository.find_by_name("Friends Historical Library: Swarthmore College")
    repo_path = "http://tricontentdm.brynmawr.edu/oai/oai.php"
    base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
    identifiers = ['oai:tricontentdm.brynmawr.edu:HC_QuakSlav/12403']
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers, metadata_prefix)
  end

  task from_haverford: :environment do
    repository = Repository.find_by_name("Haverford College Library, Quaker & Special Collections")
    repo_path = "http://tricontentdm.brynmawr.edu/oai/oai.php"
    base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
    identifiers = ['oai:tricontentdm.brynmawr.edu:HC_DigReq/19215', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19217', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19224', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19231', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19237', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19249', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19246', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19241', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19252', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19259', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19262', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19265', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19270', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19272', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19276']
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers, metadata_prefix)
  end

### CSV IMPORTS ########################################################################################

  def import_from_csv(filepath, repository, original_entry_date)
    ns = {
        "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
    }
    CSV.foreach(filepath, headers: true) do |row|
      if RawRecord.find_by_oai_identifier(row[1]).blank?
        raw_record = RawRecord.new
        raw_record.repository_id = repository.id
        raw_record.original_record_url = row[6]
        raw_record.oai_identifier = row[1]
        raw_record.original_entry_date = original_entry_date # hardcoded until we get a filenaming scheme

        builder = Nokogiri::XML::Builder.new { |xml|
          xml.metadata {
            xml.contributing_repository row[0]
            xml['oai_qdc'].qualifieddc(ns) do
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

  task from_bates: :environment do
    repository = Repository.find_by_name("Barbara Bates Center for the Study of the History of Nursing | University of Pennsylvania School of Nursing")
    filepath = "lib/documents/csv/bates_center/BatesCenter.csv"
    original_entry_date = "2017-3-13" # hardcoded until we get a filenaming scheme
    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_library_co: :environment do
    repository = Repository.find_by_name("The Library Company of Philadelphia")
    filepath = "lib/documents/csv/library_company/LibraryCompany.csv"
    original_entry_date = "2017-4-26" # hardcoded until we get a filenaming scheme
    import_from_csv(filepath, repository, original_entry_date)
  end

end
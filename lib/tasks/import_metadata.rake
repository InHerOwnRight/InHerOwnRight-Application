require 'oai'
require "csv"

namespace :import_metadata do
  desc "Import metadata raw_records from repositories"

  task all: [:collections, :from_temple, :from_swarthmore, :from_drexel, :from_bates, :from_library_co, :from_haverford, :from_hsp] do
  end

  def import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
    client = OAI::Client.new  repo_path, :headers => { "From" => "oai@example.com" }
    identifiers_relations_hash.each do |identifier, relations_nodes|

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
          if !relations_nodes.blank?
            processed_xml_document = Nokogiri::XML.parse(response_record.metadata.to_s)
            relations_nodes.each do |node|
              processed_xml_document.first_element_child.first_element_child.add_child(node)
            end
            raw_record.xml_metadata = processed_xml_document
          else
            raw_record.xml_metadata = response_record.metadata
          end
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
    identifiers_relations_hash = {}
    set_specs = ['p15037coll19', 'p15037coll14']

    set_specs.map do |set|
      client = OAI::Client.new "http://digital.library.temple.edu/oai/oai.php", :headers => { "From" => "oai@example.com" }
      client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
        xml_metadata = Nokogiri::XML.parse(record.metadata.to_s)
        xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/").each do |relation_node|
          if relation_node.text.include?("In Her Own Right")
            identifiers_relations_hash[record.header.identifier] = xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/")
          end
        end
      end
    end
    repository = Repository.find_by_name("Temple University Libraries")
    repo_path = 'http://digital.library.temple.edu/oai/oai.php'
    base_response_record_path = 'http://digital.library.temple.edu/cdm/ref/collection/'
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
  end

  task from_drexel: :environment do
    identifiers_relations_hash = {}
    set_specs = ['lca_3']

    set_specs.map do |set|
      client = OAI::Client.new "https://idea.library.drexel.edu/oai/request", :headers => { "From" => "oai@example.com" }
      client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
        identifiers_relations_hash[record.header.identifier] = ''
      end
    end

    repository = Repository.find_by_name("Drexel University College of Medicine Legacy Center")
    repo_path = "https://idea.library.drexel.edu/oai/request"
    base_response_record_path = "http://hdl.handle.net/1860/"
    metadata_prefix = "oai_dc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
  end

  task from_swarthmore: :environment do
    identifiers_relations_hash = {}
    repository = Repository.find_by_name("Friends Historical Library: Swarthmore College")
    repo_path = "http://tricontentdm.brynmawr.edu/oai/oai.php"
    base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
    identifiers_relations_hash['oai:tricontentdm.brynmawr.edu:HC_QuakSlav/12403'] = ''
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
  end

  task from_haverford: :environment do
    repository = Repository.find_by_name("Haverford College Library, Quaker & Special Collections")
    repo_path = "http://tricontentdm.brynmawr.edu/oai/oai.php"
    base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
    identifiers_relations_hash = {}
    identifiers = ['oai:tricontentdm.brynmawr.edu:HC_DigReq/19215', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19217', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19224', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19231', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19237', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19249', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19246', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19241', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19252', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19259', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19262', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19265', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19270', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19272', 'oai:tricontentdm.brynmawr.edu:HC_DigReq/19276']
    identifiers.map{|id| identifiers_relations_hash[id] = ''}
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
  end

### CSV IMPORTS ########################################################################################

  task collections: :environment do
    name_spaces = {
        "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
    }
    CSV.foreach('lib/documents/csv/collections.csv', headers: true) do |row|
      if RawRecord.find_by_oai_identifier(row[4]).nil?
        repository = Repository.find_by_name(row[0])
        raw_record = RawRecord.new
        raw_record.record_type = "collection"
        raw_record.repository_id = repository.id
        raw_record.original_record_url = row[7]
        raw_record.oai_identifier = row[7]
        builder = Nokogiri::XML::Builder.new { |xml|
          xml.metadata {
            xml.contributing_repository row[0]
            xml['oai_qdc'].qualifieddc(name_spaces) do
              xml['dc'].title row[1]
              xml['dc'].creator row[2]
              xml['dc'].date row[3]
              xml['dc'].identifier row[4]
              xml['dc'].coverage row[5]
              xml['dc'].extent row[6]
              if !row[7].blank?
                xml['dc'].identifier row[7]
              end
              if row[8].split(":").first == "http" || row[8].split(":").first == "https"
                xml['dc'].identifier row[8]
              else
                xml['dc'].hasFormat row[8]
              end
              xml['dc'].description row[9]
              xml['dc'].description row[10]
            end
          }
        }
        raw_record.xml_metadata = builder.to_xml
        raw_record.save
      end
    end
  end

  def import_from_csv(filepath, repository, original_entry_date)
    name_spaces = {
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
            xml['oai_qdc'].qualifieddc(name_spaces) do
              xml['dc'].identifier row[1]
              xml['dc'].title row[2]
              xml['dcterms'].created row[3]
              xml['dc'].creator row[4]
              xml['dcterms'].licence row[5]
              xml['dc'].identifier row[6]
              xml['dc'].type row[7]
              xml['dc'].language row[8]
              xml['dcterms'].extent row[9]
              if row[10] =~ /\\|/
                subjects = row[10].split("|")
                subjects.each do |subj|
                  xml['dc'].subject subj
                end
              elsif row[10] =~ /;/
                subjects = row[10].split(";")
                subjects.each do |subj|
                  xml['dc'].subject subj
                end
              else
                xml['dc'].subject row[10]
              end
              xml['dcterms'].spacial row[11]
              xml['dc'].description row[12]
              xml['dc'].publisher row[13]
              xml['dcterms'].isPartOf row[14]
              xml['dcterms'].text row[15]
              xml['dcterms'].localData row[16]
              xml['dcterms'].localData row[17]
              xml['dcterms'].localData row[18]
              xml['dcterms'].isPartOf row[19]
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

  task from_hsp: :environment do
    repository = Repository.find_by_name("Historical Society of Pennsylvania")
    filepath = "lib/documents/csv/hsp/HSP.csv"
    original_entry_date = "2017-4-26" # hardcoded until we get a filenaming scheme
    import_from_csv(filepath, repository, original_entry_date)
  end

end
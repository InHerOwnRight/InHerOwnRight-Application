require 'oai'
require "csv"
require 'pry'

namespace :import_metadata do

  # Error messages different versions of OAI-PMH return when no records are returned
  EmptyImportErrors = [ "The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list.",
                        "The combination of the given values results in an empty list."]

  desc "Import metadata raw_records from repositories"


  task all_oai: [:from_temple, :from_swarthmore, :from_drexel, :from_haverford]
  task all_csv: [:collections, :from_bates, :from_library_co, :from_hsp, :from_hsp2, :from_bates2]
  # OAI tasks must come before CSV tasks to maintain the marker date for the last OAI data pull
  task all: [:all_oai, :all_csv]

  def import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
    client = OAI::Client.new  repo_path, :headers => { "From" => "oai@example.com" }
    nil_metadata_identifiers = []
    identifiers_relations_hash.each do |identifier, relations_nodes|
      response = client.get_record({identifier: identifier, metadata_prefix: metadata_prefix})
      response_record = response.record
      raw_record = RawRecord.find_or_initialize_by(oai_identifier: response_record.header.identifier)

      if !response_record.header.set_spec.first.text.blank?
        raw_record.set_spec = response_record.header.set_spec.first.text
        raw_record.original_record_url = "#{base_response_record_path}#{raw_record.set_spec}/id/#{identifier.split('/').last}"
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
      else
        nil_metadata_identifiers << response_record.header.identifier
      end

      raw_record.repository_id = repository.id

      if raw_record.save
        puts "Successfully imported #{raw_record.oai_identifier}"
      else
        puts "Something went wrong."
      end
    end
    puts nil_metadata_identifiers
  end

  task from_temple: :environment do
    identifiers_relations_hash = {}
    set_specs = ['p15037coll19', 'p15037coll14']
    repository = Repository.find_by_name("Temple University Libraries")

    relation_text = ["Octavia Hill Association (Philadelphia, Pa.) Records", "Young Women's Christian Association - Metropolitan Branch, Acc. URB 23", "YWCA of Philadelphia - Kensington Branch, Acc. 520, 531, 552", "YWCA of Germantown, Acc. 280", "In Her Own Right"]

    set_specs.map do |set|
      client = OAI::Client.new "http://digital.library.temple.edu/oai/oai.php", :headers => { "From" => "oai@example.com" }
      if repository.raw_records.empty?
        client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
          xml_metadata = Nokogiri::XML.parse(record.metadata.to_s)
          xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/").each do |relation_node|
            relation_text.each do |text|
              if relation_node.text.include?(text)
                identifiers_relations_hash[record.header.identifier] = xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/")
              end
            end
          end
        end
      else
        # Subtract a day in case timezones are off. Better to update something that hasn't changed than miss an update
        last_update = repository.raw_records.order('updated_at DESC').first.updated_at.to_date - 1.day
        begin
          client.list_records(metadata_prefix: 'oai_dc', set: "#{set}", from: last_update).full.each do |record|
            xml_metadata = Nokogiri::XML.parse(record.metadata.to_s)
            xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/").each do |relation_node|
              relation_text.each do |text|
                if relation_node.text.include?(text)
                  identifiers_relations_hash[record.header.identifier] = xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/")
                end
              end
            end
          end
        rescue OAI::Exception => e
          if EmptyImportErrors.include?(e.message.strip)
            puts "All Temple OAI records for set #{set} are up to date as of #{last_update}."
          else
            puts "!!from_date is #{last_update}"
            raise e
          end
        end
      end
    end
    repo_path = 'http://digital.library.temple.edu/oai/oai.php'
    base_response_record_path = 'http://digital.library.temple.edu/cdm/ref/collection/'
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
  end

  task from_drexel: :environment do
    identifiers_relations_hash = {}
    repo_path = "https://idea.library.drexel.edu/oai/request"
    set_specs = ['lca_3']
    repository = Repository.find_by_name("Drexel University College of Medicine Legacy Center")

    set_specs.map do |set|
      client = OAI::Client.new repo_path, :headers => { "From" => "http://inherownright.org" }
      if repository.raw_records.empty?
        client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
          identifiers_relations_hash[record.header.identifier] = ''
        end
      else
        # Drexel will accept a date or time here, but the others require a date. So standardize
        # Subtract a day in case timezones are off. Better to update something that hasn't changed than miss an update
        last_update = repository.raw_records.order('updated_at DESC').first.updated_at.to_date - 1.day
        begin
          client.list_records(metadata_prefix: 'oai_dc', set: "#{set}", from: last_update).full.each do |record|
            identifiers_relations_hash[record.header.identifier] = ''
          end
        rescue OAI::Exception => e
          if EmptyImportErrors.include?(e.message.strip)
            puts "All Drexel OAI records for set #{set} are up to date as of #{last_update}."
          else
            raise e
          end
        end
      end
    end

    repository = Repository.find_by_name("Drexel University College of Medicine Legacy Center")
    base_response_record_path = "http://hdl.handle.net/1860/"
    metadata_prefix = "oai_dc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
  end

  task from_swarthmore: :environment do
    identifiers_relations_hash = {}
    repo_path = "http://tricontentdm.brynmawr.edu/oai/oai.php"
    set_specs = ['InHOR']
    repository = Repository.find_by_name("Friends Historical Library: Swarthmore College")

    set_specs.map do |set|
      client = OAI::Client.new repo_path, :headers => { "From" => "http://inherownright.org" }
      if repository.raw_records.empty?
        begin
          client.list_records(metadata_prefix: 'oai_dc', set: "#{set}").full.each do |record|
            identifiers_relations_hash[record.header.identifier] = ''
          end
        rescue OAI::Exception => e
          if EmptyImportErrors.include?(e.message.strip)
            puts "The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list."
            base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
            metadata_prefix = "oai_qdc"
            import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix)
            next
          else
            raise e
          end
        end
      else
        # Subtract a day in case timezones are off. Better to update something that hasn't changed than miss an update
        last_update = repository.raw_records.order('updated_at DESC').first.updated_at.to_date - 1.day
        begin
          client.list_records(metadata_prefix: 'oai_dc', set: "#{set}", from: last_update).full.each do |record|
            identifiers_relations_hash[record.header.identifier] = ''
          end
        rescue OAI::Exception => e
          if EmptyImportErrors.include?(e.message.strip)
            puts "All Swarthmore OAI records for set #{set} are up to date as of #{last_update}."
          else
            raise e
          end
        end
      end
    end

    base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
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
      repository = Repository.find_by_name(row[0])
      raw_record = RawRecord.find_or_initialize_by(oai_identifier: row[7])
      raw_record.record_type = "collection"
      raw_record.repository_id = repository.id
      raw_record.original_record_url = row[7]
      builder = Nokogiri::XML::Builder.new { |xml|
        xml.metadata {
          xml.contributing_repository row[0]
          xml['oai_qdc'].qualifieddc(name_spaces) do
            xml['dc'].title row[1]
            if !row[2].blank?
              xml['dc'].creator row[2]
            end
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
            xml['dc'].description row[11]
          end
        }
      }
      raw_record.xml_metadata = builder.to_xml
      raw_record.save
    end
  end

  def import_from_csv(filepath, repository, original_entry_date)
    name_spaces = {
        "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
        "xmlns:dcterms" => "http://purl.org/dc/terms/",
        "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
    }
    CSV.foreach(filepath, headers: true) do |row|
      raw_record = RawRecord.find_or_initialize_by(oai_identifier: row[1])
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
            if row[10] =~ /\;/
              subjects = row[10].split("; ")
              subjects.each do |subj|
                xml['dc'].subject subj
              end
            elsif row[10] =~ /\\|/
              subjects = row[10].split("|")
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

  task from_hsp2: :environment do
    repository = Repository.find_by_name("Historical Society of Pennsylvania")
    filepath = "lib/documents/csv/hsp/HSP2.csv"
    original_entry_date = "2017-4-26" # hardcoded until we get a filenaming scheme

    import_from_csv2(filepath, repository, original_entry_date)
  end

  task from_bates2: :environment do
    repository = Repository.find_by_name("Barbara Bates Center for the Study of the History of Nursing | University of Pennsylvania School of Nursing")
    filepath = "lib/documents/csv/bates_center/BatesCenter2.csv"
    original_entry_date = "2019-5-15" # hardcoded until we get a filenaming scheme

    import_from_csv2(filepath, repository, original_entry_date)
  end
end

def import_from_csv2(filepath, repository, original_entry_date)
  name_spaces = {
      "xmlns:oai_qdc" => "http://worldcat.org/xmlschemas/qdc-1.0/",
      "xmlns:dcterms" => "http://purl.org/dc/terms/",
      "xmlns:dc"      => "http://purl.org/dc/elements/1.1/"
  }

  CSV.foreach(filepath, headers: true) do |row|
    raw_record = RawRecord.find_or_initialize_by(oai_identifier: row[0])
    raw_record.repository_id = repository.id
    raw_record.original_record_url = row[1]
    raw_record.oai_identifier = row[0]
    raw_record.original_entry_date = original_entry_date # hardcoded until we get a filenaming scheme

    @full_text = nil
    if row[16] == "y" || row[16] == "Y"
      CSV.foreach("lib/documents/csv/hsp/HSP2_full_text.csv", headers: true) do |text_row|
        if text_row[0] == row[0] && !text_row[1].nil?
          @full_text = text_row[1]
        end
      end
    end

    builder = Nokogiri::XML::Builder.new { |xml|
      xml.metadata {
        xml.contributing_repository row[2]
        xml['oai_qdc'].qualifieddc(name_spaces) do
          xml['dc'].identifier row[0]
          xml['dc'].title row[3]
          xml['dcterms'].created row[4]
          xml['dcterms'].created row[5]
          xml['dc'].creator row[6]
          xml['dcterms'].licence row[7]
          xml['dc'].identifier row[1]
          xml['dc'].type row[10]
          xml['dc'].language row[8]
          xml['dcterms'].extent row[11]
          if row[9] =~ /\;/
            subjects = row[9].split("; ")
            subjects.each do |subj|
              xml['dc'].subject subj
            end
          elsif row[9] =~ /\\|/
            subjects = row[9].split("|")
            subjects.each do |subj|
              xml['dc'].subject subj
            end
          else
            xml['dc'].subject row[9]
          end
          xml['dcterms'].spacial row[12]
          xml['dc'].description row[13]
          xml['dc'].publisher row[14]
          xml['dcterms'].isPartOf row[15]
          xml['dcterms'].text_ @full_text
          xml['dcterms'].localData row[17]
          xml['dcterms'].localData row[18]
          xml['dcterms'].localData row[19]
        end
      }
    }
    raw_record.xml_metadata = builder.to_xml
    raw_record.save
  end
end

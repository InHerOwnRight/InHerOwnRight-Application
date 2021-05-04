require 'oai'
require "csv"
require "./app/helpers/import_record_collections_helper.rb"

namespace :import_metadata do

  # Error messages different versions of OAI-PMH return when no records are returned
  EmptyImportErrors = [ "The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list.",
                        "The combination of the given values results in an empty list."]

  desc "Import metadata raw_records from repositories"

  task all_oai: [:bryn_mawr, :temple, :tri_colleges, :drexel, :haverford]
  task all_csv: [:from_bates, :from_library_co, :from_hsp, :from_german_society, :from_udel,
                 :from_nara, :from_catholic, :from_college_of_physicians, :from_presbyterian,
                 :from_union_league, :collections]
  # OAI tasks must come before CSV tasks to maintain the marker date for the last OAI data pull
  task all: [:all_oai, :all_csv]

  def import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, harvest_id)
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

      friends = Repository.find_by_short_name("Swarthmore - Friends")
      peace = Repository.find_by_short_name("Swarthmore - Peace")
      haverford = Repository.find_by_short_name("Haverford College")

      raw_record.repository_id = repository.id
      if !raw_record.xml_metadata.nil?
        raw_record.repository_id = friends.id if raw_record.xml_metadata.include?("Friends Historical Library of Swarthmore College")
        raw_record.repository_id = peace.id if raw_record.xml_metadata.include?("Swarthmore College Peace Collection")
        raw_record.repository_id = haverford.id if raw_record.xml_metadata.include?("isPartOf>Haverford")
      end

      raw_record.harvest_id = harvest_id

      if raw_record.save
        puts "Successfully imported #{raw_record.oai_identifier}"
      else
        puts "Something went wrong."
      end
    end
    puts nil_metadata_identifiers
  end

  def import_islandora_metadata(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, harvest_id)
    client = OAI::Client.new  repo_path, :headers => { "From" => "oai@example.com" }
    nil_metadata_identifiers = []
    identifiers_relations_hash.each do |identifier, relations_nodes|
      response = client.get_record({identifier: identifier, metadata_prefix: metadata_prefix})
      response_record = response.record
      raw_record = RawRecord.find_or_initialize_by(oai_identifier: response_record.header.identifier)

      if !response_record.header.set_spec.first.text.blank?
        raw_record.set_spec = response_record.header.set_spec.first.text
        raw_record.original_record_url = "#{base_response_record_path}#{identifier.split(":").last.delete("_")}"
      end

      if !response_record.header.identifier.blank?
        raw_record.oai_identifier = response_record.header.identifier
      end

      if !response_record.header.datestamp.blank?
        raw_record.original_entry_date = response_record.header.datestamp
      end

      if !response_record.metadata.blank?
        islandora_metadata = client.get_record(metadata_prefix: 'oai_dc', identifier: identifier).record.metadata.to_s
        if !relations_nodes.blank?
          processed_xml_document = Nokogiri::XML.parse(islandora_metadata)
          relations_nodes.each do |node|
            processed_xml_document.first_element_child.first_element_child.add_child(node)
          end
          raw_record.xml_metadata = processed_xml_document
        else
          raw_record.xml_metadata = islandora_metadata
        end
      else
        nil_metadata_identifiers << response_record.header.identifier
      end

      raw_record.repository_id = repository.id
      raw_record.harvest_id = harvest_id

      if raw_record.save
        puts "Successfully imported #{raw_record.oai_identifier}"
      else
        puts "Something went wrong."
      end
    end
    puts nil_metadata_identifiers
  end

  task :temple, [:harvest_id] => [:environment] do |t, args|
    identifiers_relations_hash = {}
    set_specs = ['p15037coll19', 'p15037coll14', 'p15037coll15']
    repository = Repository.find_by_short_name("Temple University")

    relation_text = ["Octavia Hill Association (Philadelphia, Pa.) Records", "Young Women's Christian Association - Metropolitan Branch, Acc. URB 23", "YWCA of Philadelphia - Kensington Branch, Acc. 520, 531, 552", "YWCA of Germantown, Acc. 280", "In Her Own Right"]

    set_specs.map do |set|
      client = OAI::Client.new "http://digital.library.temple.edu/oai/oai.php", :headers => { "From" => "oai@example.com" }
      response = client.list_records(metadata_prefix: 'oai_dc', set: "#{set}")
      metadata_records = []
      response.each { |r| metadata_records << r }
      until response.resumption_token.nil?
        response = client.list_records(resumption_token: response.resumption_token)
        response.each { |r| metadata_records << r }
      end
      metadata_records.each do |record|
        xml_metadata = Nokogiri::XML.parse(record.metadata.to_s)
        xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/").each do |relation_node|
          if relation_node.text.include?("In Her Own Right")
            identifiers_relations_hash[record.header.identifier] = xml_metadata.xpath("//dc:relation", "dc" => "http://purl.org/dc/elements/1.1/")
          end
        end
      end
    end
    repo_path = 'http://digital.library.temple.edu/oai/oai.php'
    base_response_record_path = 'http://digital.library.temple.edu/cdm/ref/collection/'
    metadata_prefix = "oai_qdc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
  end

  task :drexel, [:harvest_id] => [:environment] do |t, args|
    identifiers_relations_hash = {}
    repo_path = "https://idea.library.drexel.edu/oai/request"
    set_specs = ['lca_3']
    repository = Repository.find_by_short_name("Drexel University")

    set_specs.map do |set|
      client = OAI::Client.new repo_path, :headers => { "From" => "http://inherownright.org" }
      response = client.list_records(metadata_prefix: 'oai_dc', set: "#{set}")
      metadata_records = []
      response.each { |r| metadata_records << r }
      until response.resumption_token.nil?
        response = client.list_records(resumption_token: response.resumption_token)
        response.each { |r| metadata_records << r }
      end
      metadata_records.each do |record|
        identifiers_relations_hash[record.header.identifier] = ''
      end
    end

    repository = Repository.find_by_short_name("Drexel University")
    base_response_record_path = "http://hdl.handle.net/1860/"
    metadata_prefix = "oai_dc"
    import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
  end

  task :tri_colleges, [:harvest_id] => [:environment] do |t, args|
    identifiers_relations_hash = {}
    repo_path = "http://tricontentdm.brynmawr.edu/oai/oai.php"
    set_specs = ['InHOR']

    friends = Repository.find_by_short_name("Swarthmore - Friends")
    peace = Repository.find_by_short_name("Swarthmore - Peace")
    haverford = Repository.find_by_short_name("Haverford College")

    set_specs.map do |set|
      client = OAI::Client.new repo_path, :headers => { "From" => "http://inherownright.org" }
      begin
        response = client.list_records(metadata_prefix: 'oai_dc', set: "#{set}")
        metadata_records = []
        response.each { |r| metadata_records << r }
        until response.resumption_token.nil?
          response = client.list_records(resumption_token: response.resumption_token)
          response.each { |r| metadata_records << r }
        end
        metadata_records.each do |record|
          identifiers_relations_hash[record.header.identifier] = ''
        end
      rescue OAI::Exception => e
        if EmptyImportErrors.include?(e.message.strip)
          puts "The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list."
          base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
          metadata_prefix = "oai_qdc"
          import_from_oai_client(repository, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
          next
        else
          raise e
        end
      end
    end

    base_response_record_path = 'http://tricontentdm.brynmawr.edu/cdm/ref/collection/'
    metadata_prefix = "oai_qdc"
    import_from_oai_client(friends, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
  end

  task :bryn_mawr, [:harvest_id] => [:environment] do |t, args|
    identifiers_relations_hash = {}
    repo_path = "https://digitalcollections.tricolib.brynmawr.edu/oai2"
    bryn_mawr = Repository.find_by_short_name("Bryn Mawr College")
    client = OAI::Client.new repo_path, :headers => { "From" => "http://inherownright.org" }

    begin
      response = client.list_records(metadata_prefix: 'oai_dc', set: 'bmc_in-her-own-right')
      metadata_records = []
      response.each { |r| metadata_records << r }
      until response.resumption_token.nil?
        response = client.list_records(resumption_token: response.resumption_token)
        response.each { |r| metadata_records << r }
      end
      metadata_records.each do |record|
        identifiers_relations_hash[record.header.identifier] = ''
      end
    rescue OAI::Exception => e
      if EmptyImportErrors.include?(e.message.strip)
        puts "The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list."
        base_response_record_path = 'https://digitalcollections.tricolib.brynmawr.edu/object/'
        metadata_prefix = "oai_qdc"
        import_islandora_metadata(bryn_mawr, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
        next
      else
        raise e
      end
    end

    base_response_record_path = 'https://digitalcollections.tricolib.brynmawr.edu/object/'
    metadata_prefix = "oai_qdc"
    import_islandora_metadata(bryn_mawr, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
  end

  task :haverford, [:harvest_id] => [:environment] do |t, args|
    identifiers_relations_hash = {}
    repo_path = "https://digitalcollections.tricolib.brynmawr.edu/oai2"
    bryn_mawr = Repository.find_by_short_name("Haverford College")
    client = OAI::Client.new repo_path, :headers => { "From" => "http://inherownright.org" }

    begin
      response = client.list_records(metadata_prefix: 'oai_dc', set: 'hc_in-her-own-right')
      metadata_records = []
      response.each { |r| metadata_records << r }
      until response.resumption_token.nil?
        response = client.list_records(resumption_token: response.resumption_token)
        response.each { |r| metadata_records << r }
      end
      metadata_records.each do |record|
        identifiers_relations_hash[record.header.identifier] = ''
      end
    rescue OAI::Exception => e
      if EmptyImportErrors.include?(e.message.strip)
        puts "The combination of the values of the from, until, set and metadataPrefix arguments results in an empty list."
        base_response_record_path = 'https://digitalcollections.tricolib.brynmawr.edu/object/'
        metadata_prefix = "oai_qdc"
        import_islandora_metadata(bryn_mawr, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
        next
      else
        raise e
      end
    end

    base_response_record_path = 'https://digitalcollections.tricolib.brynmawr.edu/object/'
    metadata_prefix = "oai_qdc"
    import_islandora_metadata(bryn_mawr, repo_path, base_response_record_path, identifiers_relations_hash, metadata_prefix, args[:harvest_id])
  end

### CSV IMPORTS ########################################################################################

  task from_bates: :environment do
    repository = Repository.find_by_short_name("Barbara Bates Center")
    filepath = "lib/documents/csv/bates_center/BatesCenter.csv"
    original_entry_date = "2017-3-13" # hardcoded until we get a filenaming scheme
    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_library_co: :environment do
    repository = Repository.find_by_short_name("Library Company")
    filepath = "lib/documents/csv/library_company/LibraryCompany.csv"
    original_entry_date = "2017-4-26" # hardcoded until we get a filenaming scheme
    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_hsp: :environment do
    repository = Repository.find_by_short_name("Historical Society of PA")
    filepath = "lib/documents/csv/hsp/HSP.csv"
    original_entry_date = "2017-4-26" # hardcoded until we get a filenaming scheme
    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_german_society: :environment do
    repository = Repository.find_by_short_name("The German Society")
    filepath = "lib/documents/csv/german_society/german_society.csv"
    original_entry_date = "2019-10-23" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_udel: :environment do
    repository = Repository.find_by_short_name("University of Delaware")
    filepath = "lib/documents/csv/udel/udel.csv"
    original_entry_date = "2019-10-23" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_nara: :environment do
    repository = Repository.find_by_short_name("National Archives")
    filepath = "lib/documents/csv/nara/nara.csv"
    original_entry_date = "2019-10-23" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_catholic: :environment do
    repository = Repository.find_by_short_name("Catholic Historical Research Center")
    filepath = "lib/documents/csv/catholic/CHRC.csv"
    original_entry_date = "2020-03-03" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_college_of_physicians: :environment do
    repository = Repository.find_by_short_name("College of Physicians")
    filepath = "lib/documents/csv/college_of_physicians/CollegeOfPhysicians.csv"
    original_entry_date = "2020-03-03" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_presbyterian: :environment do
    repository = Repository.find_by_short_name("Presbyterian Historical Society")
    filepath = "lib/documents/csv/presbyterian/PHS.csv"
    original_entry_date = "2020-03-03" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task from_union_league: :environment do
    repository = Repository.find_by_short_name("Legacy Foundation")
    filepath = "lib/documents/csv/union_league/UnionLeague.csv"
    original_entry_date = "2020-03-03" # hardcoded until we get a filenaming scheme

    import_from_csv(filepath, repository, original_entry_date)
  end

  task collections: :environment do
    ImportRecordCollectionsHelper.create_raw_records
  end
end

def import_from_csv(filepath, repository, original_entry_date)
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

    builder = Nokogiri::XML::Builder.new { |xml|
      xml.metadata {
        xml.contributing_repository row[2]
        xml['oai_qdc'].qualifieddc(name_spaces) do
          xml['dc'].identifier row[0]
          if row[1]
            xml['dc'].identifier row[1]
          end
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
          xml['dc'].description row[16]
        end
      }
    }
    raw_record.xml_metadata = builder.to_xml
    raw_record.save
  end
end

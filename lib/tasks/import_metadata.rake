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

end
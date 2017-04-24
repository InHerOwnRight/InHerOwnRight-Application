require 'oai'
namespace :import_metadata do
  desc "Import metadata raw_records from repositories"

  task from_temple: :environment do
    repository = Repository.find_by_name("Temple University Libraries")
    temple_path = 'http://digital.library.temple.edu/oai/oai.php'
    base_raw_record_path = 'http://digital.library.temple.edu/cdm/ref/collection/'
    client = OAI::Client.new temple_path, :headers => { "From" => "oai@example.com" }

    identifiers = ['oai:digital.library.temple.edu:p15037coll19/1208', 'oai:digital.library.temple.edu:p15037coll19/1258', 'oai:digital.library.temple.edu:p15037coll19/1299']

    identifiers.map do |identifier|

      if RawRecord.find_by_oai_identifier(identifier).blank?
        response = client.get_record identifier: identifier
        raw_record = response.record

        new_raw_record = RawRecord.new
        if !raw_record.header.set_spec.first.text.blank?
          new_raw_record.set_spec = raw_record.header.set_spec.first.text
          new_raw_record.original_record_url = "#{base_raw_record_path}/#{new_raw_record.set_spec}/#{identifier.split('/').last}"
        end
        if !raw_record.header.identifier.blank?
          new_raw_record.oai_identifier = raw_record.header.identifier
        end
        if !raw_record.header.datestamp.blank?
          new_raw_record.original_entry_date = raw_record.header.datestamp
        end
        if !raw_record.metadata.blank?
          new_raw_record.xml_metadata = raw_record.metadata
        end

        new_raw_record.repository_id = repository.id

        if new_raw_record.save
          puts "Successfully saved #{new_raw_record.oai_identifier}"
        else
          puts "Something went wrong."
        end

      else
        puts "#{identifier} has already been imported"
      end
    end

  end
end
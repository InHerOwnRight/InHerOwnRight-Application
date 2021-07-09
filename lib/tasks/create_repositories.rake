require 'csv'
namespace :create_repositories do
  desc "Create records and Dublin Core parts from raw records"

  task all: :environment do
    CSV.foreach('lib/documents/csv/repositories/repository_list.csv', headers: true) do |row|
      repository = Repository.find_or_initialize_by(short_name: row[1])
      repository.abbreviation = row[0]
      repository.short_name = row[1]
      repository.name = row[2]
      repository.address = row[3]
      repository.email = row[4]
      repository.url = row[5]
      repository.oai_task = row[6]
      repository.image_task = row[7]

      repository.save
    end
  end

  require 'csv'
  task csv: :environment do
    headers = ["Name", "Address", "Email", "URL"]
    CSV.open("tmp/repository_list.csv", "wb") do |csv|
      csv << headers
      repo_list.each do |repo_array|
        csv << repo_array
      end
    end
  end

end

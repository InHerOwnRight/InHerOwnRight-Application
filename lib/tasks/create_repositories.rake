require 'csv'
namespace :create_repositories do
  desc "Create records and Dublin Core parts from raw records"

  task all: :environment do
    CSV.foreach('lib/documents/csv/repositories/repository_list_MGedit.csv', headers: true) do |row|
      repository = Repository.find_or_initialize_by(name: row[1])
      repository.abbreviation = row[0]
      repository.name = row[1]
      repository.address = row[2]
      repository.email = row[3]
      repository.url = row[4]
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

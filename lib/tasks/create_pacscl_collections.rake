namespace :create_pacscl_collections do
  desc "Create pacscl_collections table from csv and updates dc_terms_is_part_ofs if in collection"

  task all: [:import_pacscl_collection_data] do
  end

  task import_pacscl_collection_data: :environment do
    # existing_pacscl_collection_ids = PacsclCollection.pluck(:id)
    CSV.foreach('lib/documents/csv/pacscl_collections.csv', headers: true) do |row|
      institution_name = row[0]
      repository = Repository.where("name like ?", "%#{institution_name}%").first
      if !repository
        puts "No repository found to match CSV data insitution name: #{institution_name}"
      else
        import_source = row[1]
        detailed_name = row[2]
        clean_name = row[3]
        pacscl_collection = PacsclCollection.find_or_initialize_by(repository: repository, import_source: import_source, detailed_name: detailed_name, clean_name: clean_name)
        puts "Pacscl collection not saved for detailed name: #{detailed_name}" unless pacscl_collection.save
      end
    end
  end
end

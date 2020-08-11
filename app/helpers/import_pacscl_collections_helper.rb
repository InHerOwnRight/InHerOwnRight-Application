require "csv"

module ImportPacsclCollectionsHelper
  def self.save_file(file)
    file_path = "#{Rails.root}/uploads/pacscl_collections/pacscl_collections.csv"
    File.write(file_path, file.read.force_encoding("UTF-8"))
  end

  def self.initiate
    existing_pacscl_collection_ids = PacsclCollection.pluck(:id)

    # create new pacscl collections or update existing
    CSV.foreach("#{Rails.root}/uploads/pacscl_collections/pacscl_collections.csv", headers: true) do |row|
      institution_name = row[0].gsub('"', '')
      repository = Repository.find_by_name(institution_name)
      if repository
        import_source = row[1].gsub('"', '')
        detailed_name = row[2].gsub('"', '')
        if row[3].nil?
          clean_name  = nil
        else
          clean_name = row[3].gsub('"', '')
        end
        pacscl_collection = PacsclCollection.find_or_initialize_by(repository: repository, import_source: import_source, detailed_name: detailed_name, clean_name: clean_name)
        if pacscl_collection.save
          existing_pacscl_collection_ids.delete(pacscl_collection.id)
        else
          puts "Pacscl collection not saved for detailed name: #{detailed_name}"
        end
      else
        raise "No repository found to match CSV data insitution name: #{institution_name}."
      end
    end

    # delete any pacscl collections no longer on csv
    if existing_pacscl_collection_ids.any?
      existing_pacscl_collection_ids.each do |existing_pacscl_collection_id|
        PacsclCollection.find(existing_pacscl_collection_id).destroy
      end
    end
  end
end

require "./app/helpers/import_pacscl_collections_helper.rb"

namespace :create_pacscl_collections do
  desc "Create pacscl_collections table from csv and updates dc_terms_is_part_ofs if in collection"

  task all: [:import_pacscl_collection_data] do
  end

  task import_pacscl_collection_data: :environment do
    ImportPacsclCollectionsHelper.initiate
  end
end

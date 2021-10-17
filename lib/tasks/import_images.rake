require 'aws-sdk-s3'

namespace :import_images do
  desc "Import images for records"

  def region
    'us-east-2'
  end

  def s3
    Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  end

  def bucket
    s3.bucket('pacscl-production')
  end


  def add_images_to_records(harvest, images_folder, image_relevance_test: nil )
    raise "Please pass a proc to image_relevance_test with record and image_path as arguments" unless image_relevance_test.is_a?(Proc)

    s3_base = "images/#{images_folder}"
    all_repo_paths = bucket.objects(prefix: s3_base).collect(&:key)
    archive_paths = bucket.objects(prefix: "#{s3_base}/Archive").collect(&:key)
    failed_paths = bucket.objects(prefix: "#{s3_base}/Failed\ Inbox").collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_relevance_test.call(record, image_path, dc_identifier)
            if /_thumb.png\Z/.match(image_path)
              record.thumbnail = "/#{image_path}"
            elsif /_lg.png\Z/.match(image_path)
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  task all_repos: [:bates, :drexel, :haverford, :hsp, :libraryco, :swarthmore, :temple, :nara, :udel, :german,
                   :bryn_mawr, :chrc, :physicians, :phs, :union, :alicepaul, :athenaeum, :cchc, :unitedlutheran,
                   :cca, :princeton, :statelibrarypa, :pwpl, :howard, :ghs, :aamp, :lasalle, :inhor]
  task all: [:all_repos, :clean_up_collection_imgs]

  desc "Import images from Bates"
  task :bates, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'Bates', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Drexel"
  task :drexel, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/Drexel').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Drexel/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Drexel/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        if dc_identifier.identifier[0..5] == "local:"
          image_paths.each do |image_path|
            if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier[7..-1])
              if image_path[-9..-1] == "thumb.png"
                record.thumbnail = "/#{image_path}"
              elsif image_path[-6..-1] == "lg.png"
                record.file_name = "/#{image_path}"
              end
              record.save
            end
          end
        end
      end
    end
  end

  desc "Import images from Haverford"
  task :haverford, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/Haverford').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Haverford/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Haverford/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      image_paths.each do |image_path|
        if !record.oai_identifier.blank? && record.oai_identifier[0..39] == "oai:tricontentdm.brynmawr.edu:HC_DigReq/"
          if !record.oai_identifier.blank? && image_path.include?(record.oai_identifier[40..-1])
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
        record.dc_identifiers.each do |dc_identifier|
          if !dc_identifier.identifier.blank?
            if dc_identifier.identifier[0..4] == "local"
              identifier = dc_identifier.identifier[7..-1]
            else
              identifier = dc_identifier.identifier
            end
            if image_path.include?(identifier)
              if image_path[-9..-1] == "thumb.png"
                record.thumbnail = "/#{image_path}"
              elsif image_path[-6..-1] == "lg.png"
                record.file_name = "/#{image_path}"
              end
              record.save
            end
          end
        end
      end
    end
  end

  desc "Import images from HSP"
  task :hsp, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/HSP').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/HSP/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/HSP/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      image_paths.each do |image_path|
        if !record.oai_identifier.blank? && image_path.include?(record.oai_identifier)
          if image_path[-9..-1] == "thumb.png"
            record.thumbnail = "/#{image_path}"
          elsif image_path[-6..-1] == "lg.png"
            record.file_name = "/#{image_path}"
          end
          record.save
        end
      end
    end
  end

  desc "Import images from Library Company"
  task :libraryco, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/LibraryCompany').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/LibraryCompany/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/LibraryCompany/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      image_paths.each do |image_path|
        if !record.oai_identifier.blank? &&  image_path.include?(record.oai_identifier)
          if image_path[-9..-1] == "thumb.png"
            record.thumbnail = "/#{image_path}"
          elsif image_path[-6..-1] == "lg.png"
            record.file_name = "/#{image_path}"
          end
          record.save
        end
      end
    end
  end

  desc "Import images from Swarthmore"
  task :swarthmore, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'Swarthmore', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Temple"
  task :temple, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'Temple', image_relevance_test: image_relevance_test)
  end

  desc "Import images from NARA"
  task :nara, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/NARA').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/NARA/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/NARA/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && (image_path[/NARA\/([^"]+)_lg.png/, 1] == dc_identifier.identifier || image_path[/NARA\/([^"]+)_thumb.png/, 1] == dc_identifier.identifier)
            if image_path[-9..-1] == "thumb.png"
              record.thumbnail = "/#{image_path}"
            elsif image_path[-6..-1] == "lg.png"
              record.file_name = "/#{image_path}"
            end
            record.save
          end
        end
      end
    end
  end

  desc "Import images from UDel"
  task :udel, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'UDel', image_relevance_test: image_relevance_test)
  end

  desc "Import images from German Society"
  task :german, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'GermanSociety', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Bryn Mawr"
  task :bryn_mawr, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/BrynMawr').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/BrynMawr/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/BrynMawr/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank?
            if dc_identifier.identifier[0..4] == "local"
              identifier = dc_identifier.identifier[7..-1]
            else
              identifier = dc_identifier.identifier
            end
            if image_path.include?(identifier)
              if image_path[-9..-1] == "thumb.png"
                record.thumbnail = "/#{image_path}"
              elsif image_path[-6..-1] == "lg.png"
                record.file_name = "/#{image_path}"
              end
              record.save
            end
          end
        end
      end
    end
  end

  desc "Import images from Catholic"
  task :chrc, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'CHRC', image_relevance_test: image_relevance_test)
  end

  desc "Import images from College of Physicians"
  task :physicians, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'CollegeOfPhysicians', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Presbyterian"
  task :phs, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'PHS', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Union League"
  task :union, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'UnionLeague', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Alice Paul"
  task :alicepaul, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'AlicePaul', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Athenaeum"
  task :athenaeum, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'Athenaeum', image_relevance_test: image_relevance_test)
  end

  desc "Import images from CCHC (formerly CCHS)"
  task :cchc, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'CCHS', image_relevance_test: image_relevance_test)
  end

  desc "Import images from United Lutheran"
  task :unitedlutheran, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'UnitedLutheran', image_relevance_test: image_relevance_test)
  end

  desc "Import images from CCA"
  task :cca, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'CCA', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Princeton"
  task :princeton, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'Princeton', image_relevance_test: image_relevance_test)
  end

  desc "Import images from State Library of PA"
  task :statelibrarypa, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'StateLibraryPA', image_relevance_test: image_relevance_test)
  end
  
  desc "Import images from Port Washington Public Library"
  task :pwpl, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? &&       image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'PWPL', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Howard"
  task :howard, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'Howard', image_relevance_test: image_relevance_test)
  end

  desc "Import images from Germantown Historical Society"
  task :ghs, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'GHS', image_relevance_test: image_relevance_test)
  end

  desc "Import images from African American Museum in Philadelphia"
  task :aamp, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'AAMP', image_relevance_test: image_relevance_test)
  end

  desc "Import images from LaSalle University"
  task :lasalle, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'LaSalle', image_relevance_test: image_relevance_test)
  end

  desc "Import images from In Her Own Right"
  task :inhor, [:harvest_id] => :environment do |t, args|
    harvest = CsvHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    image_relevance_test = Proc.new { |record,image_path,dc_identifier| !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier) }
    add_images_to_records(harvest, 'InHOR', image_relevance_test: image_relevance_test)
  end

  desc "Clean up rogue collection images"
  task clean_up_collection_imgs: :environment do
    collection_records_with_images = Record.all.select { |r| r.is_collection? && (!r.file_name.nil? || !r.file_name.nil?) }
    collection_records_with_images.each do |r|
      r.update!(file_name: nil)
      r.update!(thumbnail: nil)
    end
  end

end

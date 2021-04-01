require 'aws-sdk-s3'

namespace :import_images do
  desc "Import images for records"

  region = 'us-east-2'
  s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  bucket = s3.bucket('pacscl-production')

  task all_repos: [:bates, :drexel, :haverford, :hsp, :libraryco, :swarthmore, :temple, :nara, :udel, :german, :bryn_mawr, :chrc, :physicians, :phs, :union, :alicepaul, :athenaeum, :cchs, :unitedlutheran]
  task all: [:all_repos, :clean_up_collection_imgs]

  desc "Import images from Bates"
  task :bates, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/Bates').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Bates/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Bates/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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
    all_repo_paths = bucket.objects(prefix: 'images/Swarthmore').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Swarthmore/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Swarthmore/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
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

  desc "Import images from Temple"
  task :temple, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/Temple').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Temple/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Temple/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
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

  desc "Import images from NARA"
  task :nara, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
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
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/UDel').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UDel/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/UDel/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from German Society"
  task :german, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/GermanSociety').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/GermanSociety/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/GermanSociety/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
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
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from Catholic"
  task :chrc, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/CHRC').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/CHRC/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/CHRC/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from College of Physicians"
  task :physicians, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/CollegeOfPhysicians').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/CollegeOfPhysicians/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/CollegeOfPhysicians/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from Presbyterian"
  task :phs, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/PHS').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/PHS/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/PHS/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from Union League"
  task :union, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/UnionLeague').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UnionLeague/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/UnionLeague/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from Alice Paul"
  task :alicepaul, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/AlicePaul').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/AlicePaul/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/AlicePaul/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from Athenaeum"
  task :athenaeum, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/Athenaeum').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Athenaeum/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/Athenaeum/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from CCHS"
  task :cchs, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/CCHS').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/CCHS/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/CCHS/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Import images from United Lutheran"
  task :unitedlutheran, [:harvest_id] => :environment do |t, args|
    harvest = OAIHarvest.find(args[:harvest_id])
    harvest.update(status: 2)
    all_repo_paths = bucket.objects(prefix: 'images/UnitedLutheran').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UnitedLutheran/Archive').collect(&:key)
    failed_paths = bucket.objects(prefix: 'images/UnitedLutheran/Failed\ Inbox').collect(&:key)
    image_paths = all_repo_paths - archive_paths - failed_paths
    harvest.records.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && image_path.include?(dc_identifier.identifier)
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

  desc "Clean up rogue collection images"
  task clean_up_collection_imgs: :environment do
    collection_records_with_images = Record.all.select { |r| r.is_collection? && (!r.file_name.nil? || !r.file_name.nil?) }
    collection_records_with_images.each do |r|
      r.update!(file_name: nil)
      r.update!(thumbnail: nil)
    end
  end

end

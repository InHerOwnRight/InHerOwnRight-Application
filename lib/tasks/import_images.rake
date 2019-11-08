require 'aws-sdk-s3'
require 'pry'

namespace :import_images do
  desc "Import images for records"

  region = 'us-east-2'
  s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  bucket = s3.bucket('pacscl-production')

  task all: [:hsp, :library_company, :swarthmore, :temple, :nara, :udel, :german_society, :bryn_mawr] do
  end

  task bates: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/Bates').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Bates/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  # task bates2: :environment do
  #   all_image_paths = bucket.objects(prefix: 'images/Bates2').collect(&:key)
  #   Record.all.each do |record|
  #     record.dc_identifiers.each do |dc_identifier|
  #       all_image_paths.each do |image_path|
  #         if image_path.include?(dc_identifier.identifier)
  #           if image_path[-9..-1] == "thumb.png"
  #             record.thumbnail = "/#{image_path}"
  #           elsif image_path[-6..-1] == "lg.png"
  #             record.file_name = "/#{image_path}"
  #           end
  #           record.save
  #         end
  #       end
  #     end
  #   end
  # end

  task drexel: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/Drexel').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Drexel/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  # task drexel2: :environment do
  #   all_image_paths = bucket.objects(prefix: 'images/Drexel2').collect(&:key)
  #   Record.all.each do |record|
  #     record.dc_identifiers.each do |dc_identifier|
  #       if dc_identifier.identifier[0..5] == "local:"
  #         all_image_paths.each do |image_path|
  #           if image_path.include?(dc_identifier.identifier[7..-1])
  #             if image_path[-9..-1] == "thumb.png"
  #               record.thumbnail = "/#{image_path}"
  #             elsif image_path[-6..-1] == "lg.png"
  #               record.file_name = "/#{image_path}"
  #             end
  #             record.save
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  task haverford: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/Haverford').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Haverford/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  task hsp: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/HSP').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/HSP/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  # task hsp2: :environment do
  #   all_image_paths = bucket.objects(prefix: 'images/HSP2').collect(&:key)
  #   Record.all.each do |record|
  #     all_image_paths.each do |image_path|
  #       if !record.oai_identifier.blank?
  #         if image_path.include?(record.oai_identifier)
  #           if image_path[-9..-1] == "thumb.png"
  #             record.thumbnail = "/#{image_path}"
  #           elsif image_path[-6..-1] == "lg.png"
  #             record.file_name = "/#{image_path}"
  #           end
  #           record.save
  #         end
  #       end
  #     end
  #   end
  # end

  task library_company: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/LibraryCompany').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/LibraryCompany/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  task swarthmore: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/Swarthmore').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Swarthmore/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  # task swarthmore2: :environment do
  #   all_image_paths = bucket.objects(prefix: 'images/Swarthmore2/').collect(&:key)
  #   Record.all.each do |record|
  #     record.dc_identifiers.each do |dc_identifier|
  #       all_image_paths.each do |image_path|
  #         if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
  #           if image_path[-9..-1] == "thumb.png"
  #             record.thumbnail = "/#{image_path}"
  #           elsif image_path[-6..-1] == "lg.png"
  #             record.file_name = "/#{image_path}"
  #           end
  #           record.save
  #         end
  #       end
  #     end
  #   end
  # end

  task temple: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/Temple').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/Temple/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  task nara: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/NARA').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/NARA/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  task udel: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/UDel').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/UDel/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
      record.dc_identifiers.each do |dc_identifier|
        image_paths.each do |image_path|
          if !dc_identifier.identifier.blank? && (image_path[/UDel\/([^"]+)_lg.png/, 1] == dc_identifier.identifier || image_path[/UDel\/([^"]+)_thumb.png/, 1] == dc_identifier.identifier)
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

  task german_society: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/GermanSociety').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/GermanSociety/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  task bryn_mawr: :environment do
    all_repo_paths = bucket.objects(prefix: 'images/BrynMawr').collect(&:key)
    archive_paths = bucket.objects(prefix: 'images/BrynMawr/Archive').collect(&:key)
    image_paths = all_repo_paths - archive_paths
    Record.all.each do |record|
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

  # task temple2: :environment do
  #   all_image_paths = bucket.objects(prefix: 'images/Temple2/').collect(&:key)
  #   Record.all.each do |record|
  #     record.dc_identifiers.each do |dc_identifier|
  #       all_image_paths.each do |image_path|
  #         if image_path.include?(dc_identifier.identifier) && !dc_identifier.identifier.blank?
  #           if image_path[-9..-1] == "thumb.png"
  #             record.thumbnail = "/#{image_path}"
  #           elsif image_path[-6..-1] == "lg.png"
  #             record.file_name = "/#{image_path}"
  #           end
  #           record.save
  #         end
  #       end
  #     end
  #   end
  # end

  # require 'fileutils'
  #
  # task move_bad_files: :environment do
  #   arr = ["#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_005_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_005_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_006_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_006_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_007_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_007_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_008_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_008_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020(1)_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020(1)_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_021_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_021_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_023_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_023_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F16_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F16_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_003_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_003_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_003_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_003_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_005_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_005_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_006_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_006_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_008_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_008_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_009_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_009_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_010_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_010_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_015_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_015_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_029_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_029_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_031_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_031_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_009_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_009_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_010_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_010_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F56_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F56_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_005_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_005_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_006_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_006_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_007_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_007_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_008_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_008_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_022_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_022_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_024_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_024_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_015_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_015_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F9_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F9_002_thumb.png"]
  #
  #   arr.each do |file|
  #     FileUtils.mv(file, "/Users/WilliamBolton/Desktop/File_names_with_issues/Bates/")
  #   end
  # end
  #
  # task move_files_drexel: :environment do
  #   arr = ["/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1875_002_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1875_002_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1876_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1876_001_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1886_012_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1886_012_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1896_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1896_001_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1897_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1897_001_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1902_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1902_001_thumb.png"]
  #   arr.each do |file|
  #     FileUtils.mv(file, "/Users/WilliamBolton/Desktop/File_names_with_issues/Temple/")
  #   end
  # end

end

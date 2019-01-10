require 'aws-sdk-s3'

namespace :import_images do
  desc "Import images for records"

  region = 'us-east-2'
  s3 = Aws::S3::Resource.new(region: region, access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
  bucket = s3.bucket('pacscl-production')

  task all: [:bates, :drexel, :haverford, :hsp, :library_company, :swarthmore, :temple,
             :drexel2, :swarthmore2, :temple2, :hsp2] do
  end

  task bates: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Bates').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.match(/.+?(?=_lg.png|_thumb.png)/).to_s
      file_size = file_path.split("_").last.split(".").first
      if DcIdentifier.find_by_identifier(current_identifier).nil?
        missing_records.push(file_path)
      else
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      end
    end
    puts missing_records
  end

  task drexel: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Drexel/').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.match(/.+?(?=_\d\d\d_lg.png|_\d\d\d_thumb.png)/).to_s
      file_size = file_path.split("_").last.split(".").first
      if !DcIdentifier.find_by_identifier("local: #{current_identifier}").nil?
        record = DcIdentifier.find_by_identifier("local: #{current_identifier}").record
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task drexel2: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Drexel2/').collect(&:key).each do |file_path|
      filename = file_path.split("/").last
      match = /(.*)_00\d_lg.png/.match(filename)
      current_identifier = match && match[1]
      file_size = file_path.split("_").last.split(".").first
      if !DcIdentifier.find_by_identifier("local: #{current_identifier}").nil?
        record = DcIdentifier.find_by_identifier("local: #{current_identifier}").record
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task haverford: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Haverford').collect(&:key).each  do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      if !Record.find_by_oai_identifier("oai:tricontentdm.brynmawr.edu:HC_DigReq/#{current_identifier}").nil?
        record = Record.find_by_oai_identifier("oai:tricontentdm.brynmawr.edu:HC_DigReq/#{current_identifier}")
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task hsp: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/HSP/').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      if !Record.find_by_oai_identifier(current_identifier).nil?
        record = Record.find_by_oai_identifier(current_identifier)
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task hsp2: :environment do
    # At the time of this writing, it seems that we don't have HSP2 data yet
    missing_records = []
    bucket.objects(prefix: 'images/HSP2').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      if !Record.find_by_oai_identifier(current_identifier).nil?
        record = Record.find_by_oai_identifier(current_identifier)
        if file_size == "lg"
          puts "Updated #{record.id}"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task library_company: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/LibraryCompany').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      if !Record.find_by_oai_identifier(current_identifier).nil?
        record = Record.find_by_oai_identifier(current_identifier)
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task swarthmore: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Swarthmore/').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      if !DcIdentifier.find_by_identifier(current_identifier).nil?
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task swarthmore2: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Swarthmore2').collect(&:key).each do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      if !DcIdentifier.find_by_identifier(current_identifier).nil?
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          puts "Updated #{record.id}"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task temple: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Temple/').collect(&:key).each do |file_path|
      actual_file_name = file_path.split("/").last.split("_").first
      current_identifier = file_path.split("/").last.split("_").first.split("Y").first
      file_size = file_path.split("_").last.split(".").first
      if !DcIdentifier.find_by_identifier(current_identifier).nil?
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  task temple2: :environment do
    missing_records = []
    bucket.objects(prefix: 'images/Temple2').collect(&:key).each do |file_path|
      actual_file_name = file_path.split("/").last.split("_").first
      current_identifier = file_path.split("/").last.split("_").first.split("Y").first
      file_size = file_path.split("_").last.split(".").first
      if !DcIdentifier.find_by_identifier(current_identifier).nil?
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          puts "Updated #{record.id}"
          record.file_name = "/#{file_path}"
        else
          record.thumbnail = "/#{file_path}"
        end
        record.save
      else
        missing_records.push(file_path)
      end
    end
    puts missing_records
  end

  require 'fileutils'

  task move_bad_files: :environment do
    arr = ["#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_005_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_005_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_006_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_006_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_007_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_007_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_008_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_008_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020(1)_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020(1)_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_020_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_021_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_021_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_023_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F116_023_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F16_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F16_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_003_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F32_003_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_003_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_003_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_005_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_005_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_006_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_006_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_008_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_008_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_009_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_009_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_010_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_010_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_015_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_015_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_029_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_029_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_031_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F45_031_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_009_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_009_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_010_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F4_010_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F56_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F56_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_001_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_001_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_002_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_005_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_005_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_006_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_006_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_007_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_007_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_008_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_008_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_022_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_022_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_024_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F57_024_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_004_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_004_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_015_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F63_015_thumb.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F9_002_lg.png", "#{Rails.root}/public/images/Bates/MDHR_MC78_BX04_S6_F9_002_thumb.png"]

    arr.each do |file|
      FileUtils.mv(file, "/Users/WilliamBolton/Desktop/File_names_with_issues/Bates/")
    end
  end

  task move_files_drexel: :environment do
    arr = ["/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1875_002_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1875_002_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1876_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1876_001_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1886_012_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1886_012_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1896_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1896_001_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1897_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1897_001_thumb.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1902_001_lg.png", "/Users/WilliamBolton/Documents/neomind/pacscl/public/images/Drexel/r747_w82_1902_001_thumb.png"]
    arr.each do |file|
      FileUtils.mv(file, "/Users/WilliamBolton/Desktop/File_names_with_issues/Temple/")
    end
  end

end



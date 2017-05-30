namespace :import_images do
  desc "Import images for records"

  task all: [:bates, :drexel, :haverford, :hsp, :library_company, :swarthmore, :temple] do
  end

  task bates: :environment do
    Dir.glob("#{Rails.root}/public/images/Bates/*.png") do |file_path|
      current_identifier = file_path.split("/").last.match(/.+?(?=_lg.png|_thumb.png)/).to_s
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/Bates/#{current_identifier}_#{file_size}.png"
      if DcIdentifier.find_by_identifier(current_identifier).nil?
        puts "Something went wrong with #{current_identifier}"
      else
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          record.file_name = relative_path
        else
          record.thumbnail = relative_path
        end
        if record.save
          puts "Saving #{record.oai_identifier}"
        end
      end
    end
  end

  task drexel: :environment do
    Dir.glob("#{Rails.root}/public/images/Drexel/*.png") do |file_path|
      actual_file_name = file_path.split("/").last
      current_identifier = file_path.split("/").last.match(/.+?(?=_\d\d\d_lg.png|_\d\d\d_thumb.png)/).to_s
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/Drexel/#{actual_file_name}"
      if !DcIdentifier.find_by_identifier("local: #{current_identifier}").nil?
        record = DcIdentifier.find_by_identifier("local: #{current_identifier}").record
        if file_size == "lg"
          record.file_name = relative_path
        else
          record.thumbnail = relative_path
        end
        if record.save
          puts "Saving #{record.oai_identifier}"
        end
      else
        puts "#{file_path} failed to save."
      end
    end
  end

  task haverford: :environment do
    Dir.glob("#{Rails.root}/public/images/Haverford/*.png") do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/Haverford/#{current_identifier}_#{file_size}.png"
      if !Record.find_by_oai_identifier("oai:tricontentdm.brynmawr.edu:HC_DigReq/#{current_identifier}").nil?
        record = Record.find_by_oai_identifier("oai:tricontentdm.brynmawr.edu:HC_DigReq/#{current_identifier}")
        if file_size == "lg"
          record.file_name = relative_path
        else
          record.thumbnail = relative_path
        end
        if record.save
          puts "Saving #{record.oai_identifier}"
        end
      else
        puts "#{file_path} failed to save."
      end
    end
  end

  task hsp: :environment do
    Dir.glob("#{Rails.root}/public/images/HSP/*.png") do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/HSP/#{current_identifier}_#{file_size}.png"
      if !Record.find_by_oai_identifier(current_identifier).nil?
        record = Record.find_by_oai_identifier(current_identifier)
        if file_size == "lg"
          record.file_name = relative_path
        else
          record.thumbnail = relative_path
        end
        if record.save
          puts "Saving #{record.oai_identifier}"
        end
      else
        puts "#{file_path} failed to save."
      end
    end
  end

  task library_company: :environment do
    Dir.glob("#{Rails.root}/public/images/LibraryCompany/*.png") do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/LibraryCompany/#{current_identifier}_#{file_size}.png"
      if !Record.find_by_oai_identifier(current_identifier).nil?
        record = Record.find_by_oai_identifier(current_identifier)
        if file_size == "lg"
          record.file_name = relative_path
        else
          record.thumbnail = relative_path
        end
        if record.save
          puts "Saving #{record.oai_identifier}"
        end
      else
        puts "#{file_path} failed to save."
      end
    end
  end

    task swarthmore: :environment do
    Dir.glob("#{Rails.root}/public/images/Swarthmore/*.png") do |file_path|
      current_identifier = file_path.split("/").last.split("_").first
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/Swarthmore/#{current_identifier}_#{file_size}.png"
      if !DcIdentifier.find_by_identifier(current_identifier).nil?
        record = DcIdentifier.find_by_identifier(current_identifier).record
        if file_size == "lg"
          record.file_name = relative_path
        else
          record.thumbnail = relative_path
        end
        if record.save
          puts "Saving #{record.oai_identifier}"
        end
      else
        puts "#{file_path} failed to save."
      end
    end
  end

  task temple: :environment do
    Dir.glob("#{Rails.root}/public/images/Temple/*.png") do |file_path|
      actual_file_name = file_path.split("/").last.split("_").first
      current_identifier = file_path.split("/").last.split("_").first.split("Y").first
      file_size = file_path.split("_").last.split(".").first
      relative_path = "/images/Temple/#{actual_file_name}_#{file_size}.png"
      record = DcIdentifier.find_by_identifier(current_identifier).record
      if file_size == "lg"
        record.file_name = relative_path
      else
        record.thumbnail = relative_path
      end
      if record.save
        puts "Saving #{record.oai_identifier}"
      end
    end
  end

end



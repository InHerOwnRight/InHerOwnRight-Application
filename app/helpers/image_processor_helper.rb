require 'dotenv/load' if Rails.env.development?
require "open3"

module ImageProcessorHelper
  # each s3cmd has a production test folder file path command commented out below the actual production folder file path commands

  def self.reset_failed_inbox_image_current_status
    FailedInboxImage.update_all(current: false)
  end

  def self.create_image_process_tracker
    ImageProcessTracker.destroy_all
    ImageProcessTracker.create
  end

  def self.process_images
    delete_tmp_image_folder
    set_archive_phase
    create_failed_inbox_image_map
    reset_failed_inbox_image_table
    copy_failed_inbox_images_to_inbox
    create_inbox_image_map
    batch_process_inbox_images
    delete_image_process_tracker
    delete_tmp_image_folder
  end

  def self.reset_from_error
    ImageProcessTracker.destroy_all
    `rm -rf "tmp/images"`
    if Delayed::Job.any?
      Delayed::Job.all.each do |delayed_job|
        if delayed_job && delayed_job.last_error && delayed_job.last_error.include?('image_process')
          delayed_job.destroy
        end
      end
    end
  end

  private
    def self.set_archive_phase
      @archive_phase = 'NEH Archive'
    end

    def self.create_failed_inbox_image_map
      @failed_inbox_image_map = inbox_image_school_folders.inject({}) do |map, school_name|
        map[school_name] = failed_inbox_image_file_names(school_name)
        map
      end
    end

    def self.failed_inbox_image_file_names(school)
      raw_image_file_names = `s3cmd ls --limit=99999 "s3://pacscl-production/images/#{school}/Failed Inbox/"`
      # raw_image_file_names = `s3cmd ls --limit=99999 "s3://pacscl-production/test_images/#{school}/Failed Inbox/"`
      image_file_names = raw_image_file_names.scan(/Failed Inbox\/.+\n/)
      image_file_names.map! { |file_name| file_name.gsub("Failed Inbox/", "").gsub("\n", "") }
    end

    def self.reset_failed_inbox_image_table
      FailedInboxImage.all.each do |failed_inbox_image|
        unless image_still_in_failed_inbox?(failed_inbox_image)
          failed_inbox_image.destroy
        end
      end
    end

    def self.copy_failed_inbox_images_to_inbox
      @failed_inbox_image_map.keys.each do |school|
        FailedInboxImage.where(school: school).each do |failed_inbox_image|
          `s3cmd cp "s3://pacscl-production/images/#{school}/Failed Inbox/#{failed_inbox_image.image}" "s3://pacscl-production/images/#{school}/Inbox/#{failed_inbox_image.image}"`
          `s3cmd del "s3://pacscl-production/images/#{school}/Failed Inbox/#{failed_inbox_image.image}"`
          # `s3cmd cp "s3://pacscl-production/test_images/#{school}/Failed Inbox/#{failed_inbox_image.image}" "s3://pacscl-production/test_images/#{school}/Inbox/#{failed_inbox_image.image}"`
          # `s3cmd del "s3://pacscl-production/test_images/#{school}/Failed Inbox/#{failed_inbox_image.image}"`
        end
      end
    end

    def self.image_still_in_failed_inbox?(failed_inbox_image)
      @failed_inbox_image_map.keys.include?(failed_inbox_image.school) && @failed_inbox_image_map[failed_inbox_image.school].include?(failed_inbox_image.image)
    end

    def self.create_inbox_image_map
      @inbox_image_map = inbox_image_school_folders.inject({}) do |map, school_name|
        map[school_name] = inbox_image_file_names(school_name)
        map
      end
    end

    def self.inbox_image_school_folders
      school_folder_paths = `s3cmd ls --limit=99999 "s3://pacscl-production/images/"`
      # school_folder_paths = `s3cmd ls --limit=99999 "s3://pacscl-production/test_images/"`
      school_folders = school_folder_paths.scan(/images\/.+\//)
      school_folders.map! { |folder| folder.gsub("images", "").gsub("/", "") }
    end

    def self.inbox_image_file_names(school)
      raw_image_file_names = `s3cmd ls --limit=99999 "s3://pacscl-production/images/#{school}/Inbox/"`
      # raw_image_file_names = `s3cmd ls --limit=99999 "s3://pacscl-production/test_images/#{school}/Inbox/"`
      # [^\/] is used to ignore any images in sub-folders
      image_file_names = raw_image_file_names.scan(/Inbox\/.+[^\/]\n/)
      image_file_names.map! { |file_name| file_name.gsub("Inbox/", "").gsub("\n", "") }
    end

    def self.batch_process_inbox_images
      update_image_process_tracker_total_files
      @inbox_image_map.keys.each do |school|
        make_tmp_directory(school)
        while @inbox_image_map[school].count.positive?
          unsized_batched_inbox_image_file_names = @inbox_image_map[school].take(10)
          batched_inbox_image_file_names = remove_images_over_size_limit(school, unsized_batched_inbox_image_file_names)
          update_image_process_tracker_total_files
          if batched_inbox_image_file_names.any?
            import_inbox_images(school, batched_inbox_image_file_names)
            convert_images_to_png(school)
            resize_lg_images(school)
            resize_thumb_images(school)
            upload_processed_images(school)
            delete_local_processed_images(school)
            update_image_process_tracker_files_processed(batched_inbox_image_file_names)
          end
        end
        move_failed_inbox_images_to_failed_folder(school)
        move_inbox_images_to_archive(school)
        delete_sub_folders_from_archive(school)
        delete_inbox_images(school)
        delete_tmp_directory(school)
      end
    end

    def self.make_tmp_directory(school)
      `mkdir -p "tmp/images/#{school}/Inbox"`
    end

    def self.remove_images_over_size_limit(school, imgs)
      valid_imgs = []
      max_img_file_size = 314572800 # 300 Megabytes in Bytes
      imgs.each do |img|
        img_file_size_string = `s3cmd du \"s3://pacscl-production/images/#{school}/Inbox/#{img}\"`
        # img_file_size_string = `s3cmd du \"s3://pacscl-production/test_images/#{school}/Inbox/#{img}\"`
        img_file_size = img_file_size_string.to_i
        if img_file_size > max_img_file_size
          @inbox_image_map[school].delete(img)
          file_name = img.split("/").last
          FailedInboxImage.create(image: file_name, school: school, action: 'Review file sizes', error: "Image file too large (above #{max_img_file_size} Bytes)", failed_at: DateTime.now, current: true)
        else
          valid_imgs << img
        end
      end
      valid_imgs
    end

    def self.import_inbox_images(school, imgs)
      imgs.each do |img|
        puts "Imported #{img}"
        _stdout, stderr, status = Open3.capture3("s3cmd get \"s3://pacscl-production/images/#{school}/Inbox/#{img}\" \"./tmp/images/#{school}/Inbox/#{img}\"")
        # _stdout, stderr, status = Open3.capture3("s3cmd get \"s3://pacscl-production/test_images/#{school}/Inbox/#{img}\" \"./tmp/images/#{school}/Inbox/#{img}\"")
        file_name = img.split("/").last
        FailedInboxImage.create(image: file_name, school: school, action: 'Import from S3', error: stderr, failed_at: DateTime.now, current: true) unless status.success?
      end
      @inbox_image_map[school] = @inbox_image_map[school] - imgs
    end

    def self.convert_images_to_png(school)
      tif_images = Dir["./tmp/images/#{school}/Inbox/*"]
      tif_images.each do |img|
        if img[-2..-1] == "ff"
          png_file = img[0..-6] + ".png"
        else
          png_file = img[0..-5] + ".png"
        end
        _stdout, stderr, status = Open3.capture3("convert -quiet \"#{img}\" \"#{png_file}\"")
        file_name = img.split("/").last
        FailedInboxImage.create(image: file_name, school: school, action: 'Convert to PNG', error: stderr, failed_at: DateTime.now, current: true) unless status.success?
        File.delete(img)
      end
    end

    def self.resize_lg_images(school)
      png_images = Dir["./tmp/images/#{school}/Inbox/*.png"]
      png_images.each do |img|
        lg_file = img[0..-5] + "_lg.png"
        _stdout, stderr, status = Open3.capture3("convert -quiet \"#{img}\" -resize 500x \"#{lg_file}\"")
        file_name = img.split("/").last
        FailedInboxImage.create(image: file_name, school: school, action: 'Resize to large image', error: stderr, failed_at: DateTime.now, current: true) unless status.success?
        old_img = "#{img}"
        img.slice!("Inbox/")
        `mv "#{old_img[0..-5] + '_lg.png'}" "#{img[0..-5] + '_lg.png'}"`
      end
    end

    def self.resize_thumb_images(school)
      png_images = Dir["./tmp/images/#{school}/Inbox/*.png"]
      png_images.each do |img|
        thumb_file = img[0..-5] + "_thumb.png"
        _stdout, stderr, status = Open3.capture3("convert -quiet \"#{img}\" -resize 92x \"#{thumb_file}\"")
        file_name = img.split("/").last
        FailedInboxImage.create(image: file_name, school: school, action: 'Resize to thumbnail image', error: stderr, failed_at: DateTime.now, current: true) unless status.success?
        old_img = "#{img}"
        img.slice!("Inbox/")
        `mv "#{old_img[0..-5] + '_thumb.png'}" "#{img[0..-5] + '_thumb.png'}"`
      end
    end

    def self.upload_processed_images(school)
      `s3cmd sync --acl-public --verbose "tmp/images/#{school}/"*png "s3://pacscl-production/images/#{school}/"`
      # `s3cmd sync --acl-public --verbose "tmp/images/#{school}/"*png "s3://pacscl-production/test_images/#{school}/"`
    end

    def self.delete_local_processed_images(school)
      `rm "tmp/images/#{school}/Inbox/"*`
      `rm "tmp/images/#{school}/"*.png`
    end

    def self.move_failed_inbox_images_to_failed_folder(school)
      FailedInboxImage.where(school: school).each do |failed_inbox_image|
        `s3cmd cp "s3://pacscl-production/images/#{school}/Inbox/#{failed_inbox_image.image}" "s3://pacscl-production/images/#{school}/Failed Inbox/#{failed_inbox_image.image}"`
        `s3cmd del "s3://pacscl-production/images/#{school}/Inbox/#{failed_inbox_image.image}"`
        # `s3cmd cp "s3://pacscl-production/test_images/#{school}/Inbox/#{failed_inbox_image.image}" "s3://pacscl-production/test_images/#{school}/Failed Inbox/#{failed_inbox_image.image}"`
        # `s3cmd del "s3://pacscl-production/test_images/#{school}/Inbox/#{failed_inbox_image.image}"`
      end
    end

    def self.move_inbox_images_to_archive(school)
      `s3cmd sync --verbose "s3://pacscl-production/images/#{school}/Inbox/" "s3://pacscl-production/images/#{school}/Archive/#{@archive_phase}/"`
      # `s3cmd sync --verbose "s3://pacscl-production/test_images/#{school}/Inbox/" "s3://pacscl-production/test_images/#{school}/Archive/#{@archive_phase}/"`
    end

    def self.delete_sub_folders_from_archive(school)
      archive_file_names = `s3cmd ls -r --limit=99999 "s3://pacscl-production/images/#{school}/Archive/#{@archive_phase}/"`
      # archive_file_names = `s3cmd ls -r --limit=99999 "s3://pacscl-production/test_images/#{school}/Archive/#{@archive_phase}/"`
      folder_names = archive_file_names.scan(/ Archive\/.+\/\n/)
      folder_names.map! { |folder_name| folder_name.gsub(" Archive/", "").gsub("\n", "") }.uniq
      folder_names.each do |folder_name|
        `s3cmd del -r "s3://pacscl-production/images/#{school}/Archive/#{@archive_phase}/#{folder_name}"`
        # `s3cmd del -r "s3://pacscl-production/test_images/#{school}/Archive/#{@archive_phase}/#{folder_name}"`
      end
    end

    def self.delete_inbox_images(school)
      `s3cmd del s3://pacscl-production/images/#{school}/Inbox/*`
      # `s3cmd del s3://pacscl-production/test_images/#{school}/Inbox/*`
    end

    def self.delete_tmp_directory(school)
      `rm -rf "tmp/images/#{school}"`
    end

    def self.update_image_process_tracker_total_files
      file_count = @inbox_image_map.values.flatten.count
      ImageProcessTracker.last.update_attributes(status: 1, files_processed: 0, total_files: file_count)
    end

    def self.update_image_process_tracker_files_processed(files)
      previous_files_processed = ImageProcessTracker.last.files_processed
      new_files_processed = files.count
      files_processed = previous_files_processed + new_files_processed
      ImageProcessTracker.last.update_attributes(files_processed: files_processed)
    end

    def self.delete_image_process_tracker
      ImageProcessTracker.destroy_all
    end

    def self.delete_tmp_image_folder
      `rm -rf "tmp/images"`
    end
end

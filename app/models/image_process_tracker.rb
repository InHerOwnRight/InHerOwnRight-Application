class ImageProcessTracker < ActiveRecord::Base
  enum status: [:retrieving_file_list, :processing]

  def humanized_status
    if status == 'retrieving_file_list'
      "Retrieving file list from S3"
    elsif status == 'processing'
      "#{remaining_files} / #{total_files} files remaining"
    else
      'Unknown error'
    end
  end

  private
    def remaining_files
      total_files - files_processed
    end
end

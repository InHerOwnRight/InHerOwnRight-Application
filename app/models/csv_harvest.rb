class CsvHarvest < ActiveRecord::Base
  has_many :csv_harvest_records
  has_many :records, through: :csv_harvest_records
  has_attached_file :attachment

  validates_attachment_content_type :attachment, content_type: ['text/plain', 'text/csv', 'application/vnd.ms-excel']

  enum status: [:importing_metadata, :creating_records, :importing_images, :reindexing, :complete, :error]

  def humanized_status
    if status == 'importing_metadata'
      "Importing metadata"
    elsif status == 'creating_records'
      "Creating records"
    elsif status == 'importing_images'
      "Importing images from S3"
    elsif status == 'reindexing'
      "Reindexing records"
    elsif status == 'complete'
      "Harvest complete"
    elsif status == 'error'
      "Error"
    end
  end
end

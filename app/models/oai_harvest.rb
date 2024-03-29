class OAIHarvest < ActiveRecord::Base
  has_many :oai_harvest_records
  has_many :records, through: :oai_harvest_records
  has_many :raw_records
  belongs_to :repository
  validates :repository_id, presence: true
  enum status: [:importing_metadata, :creating_records, :importing_images, :reindexing, :complete, :error]

  delegate :s3_images_folder, to: :repository
  delegate :image_relevance_test, to: :repository

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

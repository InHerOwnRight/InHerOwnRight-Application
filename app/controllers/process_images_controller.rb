class ProcessImagesController < ApplicationController
  include ImageProcessorHelper

  before_action :authorize_current_user

  def index
    @image_process_tracker = ImageProcessTracker.last
    @failed_inbox_images = FailedInboxImage.order(:school).where(current: true)
    @schools = @failed_inbox_images.pluck(:school).uniq
    records_missing_file_names = Record.where(file_name: nil)
    records_missing_thumbnails = Record.where(thumbnail: nil)
    records_with_missing_images = records_missing_file_names.merge(records_missing_thumbnails).uniq
    csv_output = ['id', 'oai_identifier', 'slug']
    csv_output += records_with_missing_images.map do |record|
      [record.id, record.oai_identifier, record.slug]
    end
    respond_to do |format|
      format.html
      format.csv { send_data csv_output.to_csv, filename: "missing-images-#{Date.today}.csv" }
    end
  end

  def create
    ImageProcessorHelper.reset_failed_inbox_image_current_status
    ImageProcessorHelper.create_image_process_tracker
    ImageProcessorHelper.delay.process_images
    redirect_to process_images_path
  end


  private

  def authorize_current_user
    raise ActionController::RoutingError.new('Not Found') unless current_user
  end

end

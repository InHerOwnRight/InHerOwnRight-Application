class ProcessImagesController < ApplicationController
  include ImageProcessorHelper

  def index
    @image_process_tracker = ImageProcessTracker.last
    @failed_inbox_images = FailedInboxImage.order(:school)
    @schools = @failed_inbox_images.pluck(:school).uniq
    records_missing_file_names = Record.where(file_name: nil)
    records_missing_thumbnails = Record.where(thumbnail: nil)
    @records_with_missing_imgs = records_missing_file_names.merge(records_missing_thumbnails).uniq
    respond_to do |format|
      format.html
      format.csv { send_data @records_with_missing_imgs.to_csv, filename: "missing-images-#{Date.today}.csv" }
    end
  end

  def create
    ImageProcessorHelper.reset_failed_inbox_image_current_status
    ImageProcessorHelper.create_image_process_tracker
    ImageProcessorHelper.delay.process_images
    redirect_to process_images_path
  end

end
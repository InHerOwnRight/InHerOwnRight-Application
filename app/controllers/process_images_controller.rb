class ProcessImagesController < ApplicationController
  include ImageProcessorHelper

  def index
    @image_process_tracker = ImageProcessTracker.last
    @failed_inbox_images = FailedInboxImage.order(:school)
    @schools = @failed_inbox_images.pluck(:school).uniq
  end

  def create
    ImageProcessorHelper.reset_failed_inbox_image_current_status
    ImageProcessorHelper.create_image_process_tracker
    ImageProcessorHelper.delay.process_images
    redirect_to process_images_path
  end
end

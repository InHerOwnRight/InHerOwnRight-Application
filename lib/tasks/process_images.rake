require "./app/helpers/image_processor_helper.rb"

desc 'Process all images in aws s3 inbox'
task process_images: :environment do
  ImageProcessorHelper.reset_failed_inbox_image_current_status
  ImageProcessorHelper.create_image_process_tracker
  ImageProcessorHelper.delay.process_images
end

require 'aws-sdk-s3'
require 'pry'

class ImageProcessor
  def initialize(repository)
    @repository = repository
  end

  def process_images
    make_tmp_directory
    import_inbox_images
    convert_images
    resize_lg_images
    resize_thumb_images
    upload_processed_images
    move_inbox_images_to_archive
    delete_tmp_directory
  end

  private
    def make_tmp_directory
      `mkdir -p tmp_images_#{@repository}/Inbox`
    end

    def import_inbox_images
      image_paths = `s3cmd ls s3://pacscl-production/images/#{@repository}/Inbox/`
      file_paths = image_paths.split(' ').find_all { |p| p.include?(".tif") || p.include?(".png") }
      file_paths.each do |path|
        path.slice!("s3://pacscl-production/images/#{@repository}/Inbox/")
        `s3cmd get s3://pacscl-production/images/#{@repository}/Inbox/#{path} tmp_images_#{@repository}/Inbox/#{path}`
      end
    end

    def convert_images
      tif_images = Dir["./tmp_images_#{@repository}/Inbox/*f"]
      tif_images.each do |img|
        if img[-2..-1] == "ff"
          png_file = img[0..-6] + ".png"
        else
          png_file = img[0..-5] + ".png"
        end
        system("convert #{img} #{png_file}")
        File.delete(img)
      end
    end

    def resize_lg_images
      png_images = Dir["./tmp_images_#{@repository}/Inbox/*.png"]
      png_images.each do |img|
        lg_file = img[0..-5] + "_lg.png"
        system("convert #{img} -resize 500x #{lg_file}")
        old_img = "#{img}"
        img.slice!("Inbox/")
        `mv #{old_img[0..-5] + "_lg.png"} #{img[0..-5] + "_lg.png"}`
      end
    end

    def resize_thumb_images
      png_images = Dir["./tmp_images_#{@repository}/Inbox/*.png"]
      png_images.each do |img|
        thumb_file = img[0..-5] + "_thumb.png"
        system("convert #{img} -resize 92x #{thumb_file}")
        old_img = "#{img}"
        img.slice!("Inbox/")
        `mv #{old_img[0..-5] + "_thumb.png"} #{img[0..-5] + "_thumb.png"}`
        `rm #{old_img}`
      end
    end

    def upload_processed_images
      processed_images = Dir["./tmp_images_#{@repository}/*.png"]
      processed_images.each do |img|
        old_img = "#{img}"
        img.slice!("./tmp_images_#{@repository}/")
        `s3cmd put --acl-public #{old_img} s3://pacscl-production/images/#{@repository}/#{img}`
        puts "uploaded #{img}"
      end
    end

    def move_inbox_images_to_archive
      image_paths = `s3cmd ls s3://pacscl-production/images/#{@repository}/Inbox/`
      file_paths = image_paths.split(' ').find_all { |p| p.include?(".tif") || p.include?(".png") || p.include?(".tiff") }
      file_paths.each do |path|
        old_path = "#{path}"
        path.slice!("s3://pacscl-production/images/#{@repository}/Inbox/")
        `s3cmd mv #{old_path} 's3://pacscl-production/images/#{@repository}/Archive/CLIR Archive/#{path}'`
        puts "Moved #{old_path} to s3://pacscl-production/images/#{@repository}/Archive/CLIR Archive/#{path}"
      end
    end

    def delete_tmp_directory
      `rm -rf tmp_images_#{@repository}`
    end

end

repositories = ["HSP"]
repositories.each do |r|
  processor = ImageProcessor.new(r)
  processor.process_images
end

require 'aws-sdk-s3'
require 'pry'

class ImageProcessor
  def initialize(repository)
    @repository = repository
  end

  def process_images
    make_tmp_directory
    import_inbox_images
    convert_images_to_png
    resize_lg_images
    resize_thumb_images
    upload_processed_images
    move_inbox_images_to_archive
    delete_inbox_images
    delete_tmp_directory
  end

  private
    def make_tmp_directory
      `mkdir -p tmp_images_#{@repository}/Inbox`
    end

    def import_inbox_images
      `s3cmd sync s3://pacscl-production/images/#{@repository}/Inbox/ tmp_images_#{@repository}/Inbox/`
    end

    def convert_images_to_png
      tif_images = Dir["./tmp_images_#{@repository}/Inbox/*f"]
      tif_images.each do |img|
        if img[-2..-1] == "ff"
          png_file = img[0..-6] + ".png"
        else
          png_file = img[0..-5] + ".png"
        end
        system("convert '#{img}' '#{png_file}'")
        File.delete(img)
      end
    end

    def resize_lg_images
      png_images = Dir["./tmp_images_#{@repository}/Inbox/*.png"]
      png_images.each do |img|
        lg_file = img[0..-5] + "_lg.png"
        system("convert '#{img}' -resize 500x '#{lg_file}'")
        old_img = "#{img}"
        img.slice!("Inbox/")
        `mv '#{old_img[0..-5] + "_lg.png"}' '#{img[0..-5] + "_lg.png"}'`
      end
    end

    def resize_thumb_images
      png_images = Dir["./tmp_images_#{@repository}/Inbox/*.png"]
      png_images.each do |img|
        thumb_file = img[0..-5] + "_thumb.png"
        system("convert '#{img}' -resize 92x '#{thumb_file}'")
        old_img = "#{img}"
        img.slice!("Inbox/")
        `mv '#{old_img[0..-5] + "_thumb.png"}' '#{img[0..-5] + "_thumb.png"}'`
      end
    end

    def upload_processed_images
      `s3cmd sync --acl-public --verbose tmp_images_#{@repository}/*png s3://pacscl-production/images/#{@repository}/`
    end

    def move_inbox_images_to_archive
      `s3cmd sync --verbose 's3://pacscl-production/images/#{@repository}/Inbox/' 's3://pacscl-production/images/#{@repository}/Archive/CLIR Archive/'`
    end

    def delete_inbox_images
      `s3cmd del -r s3://pacscl-production/images/#{@repository}/Inbox/*`
    end

    def delete_tmp_directory
      `rm -rf tmp_images_#{@repository}`
    end

end

repositories = ["UDel"]
repositories.each do |r|
  processor = ImageProcessor.new(r)
  processor.process_images
end

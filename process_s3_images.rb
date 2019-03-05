# make temp folder for unprocessed images
# system("mkdir tmp_images")

# sync temp folder with S3 (download images)
system("s3cmd sync s3://pacscl-production/images/ /tmp/images/")
# process each image from tif to png (thumb)
# process each image from tif to png (lg)
# if processing was successful
  # save processed image in main folder (/Bates)
  # add tag to unprocessed image in Inbox
  # sync folders again with S3
  # delete temp folders

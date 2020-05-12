if Rails.env.development?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
    config.root = "#{Rails.root}/uploads/spotlight/temporary_image/image"
  end
else
  CarrierWave.configure do |config|
    config.storage = :aws
    config.aws_bucket = ENV['AWS_BUCKET']
    config.aws_acl = 'bucket-owner-full-control'

    config.aws_credentials = {
      access_key_id:      ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY'],
      region:             ENV['AWS_BUCKET_REGION']
    }
  end
end

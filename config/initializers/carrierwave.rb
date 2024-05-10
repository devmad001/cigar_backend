CarrierWave.configure do |config|
  config.storage = Rails.env.production? ? :fog : :file
  config.enable_processing = false if Rails.env.test?
  config.fog_provider = 'fog/aws'
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: ENV['S3_KEY'],
    aws_secret_access_key: ENV['S3_SECRET'],
    region: ENV['S3_REGION']
  }
  config.fog_directory = ENV['S3_BUCKET']
end

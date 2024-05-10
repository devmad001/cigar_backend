class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  EMAIL_REGEXP = /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/

  def perform_type
    ENV['JOB_PERFORM_TYPE'].blank? || ENV['JOB_PERFORM_TYPE'].to_s.downcase == 'async' ? :perform_later : :perform_now
  end

  def generate_uniq_token(key)
    while self.class.exists?(key => (token = SecureRandom.hex(32)))
    end
    token
  end

  def generate_code
    self.class.generate_code
  end

  def slug_format(str)
    self.class.slug_format str
  end

  def slug
    self.class.slug self['id'], self['title']
  end

  class << self
    include UriHelper

    def generate_code
      Random.rand(1000..9999)
    end

    def email_valid?(email)
      (email.to_s =~ ApplicationRecord::EMAIL_REGEXP).present?
    end

    def slug_format(str)
      canonize_uri str
    end

    def slug(id, title)
      slug_format [id, title].compact.join('-')
    end

    def allow_worker?
      ENV['ALLOW_WORKER'].present? && ENV['ALLOW_WORKER'] == 'true'
    end

    def s3_base_path
      ENV['S3_BUCKET'].blank? ? ENV['API_HOST'] : "https://#{ ENV['S3_BUCKET'] }.s3.amazonaws.com"
    end

    def build_image(id, file, content_type = 'image')
      return if file.blank?

      file_name = file.is_a?(CarrierWave::Uploader::Base) ? file.file.filename : file

      image_path = "/uploads/#{ self.name.underscore }/#{ id }"

      if Rails.env.development?
        image_path = "#{ ENV['API_HOST'] }#{ image_path }"
      else
        image_path = "#{ s3_base_path }#{ image_path }"
      end

      thumbnail_file_name = content_type == 'image' ? file_name : file_name.gsub(/\.([^.]+)$/, '.png')
      {
        url: "#{ image_path }/#{ file_name }",
        thumbnail: {
          url: "#{ image_path }/thumbnail_#{ thumbnail_file_name }"
        },
        medium: {
          url: "#{ image_path }/medium_#{ thumbnail_file_name }"
        }
      }
    end
  end
end

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{ model.class.to_s.underscore }/#{ model.id }"
  end

  def extension_whitelist
    %w(jpg jpeg gif png pdf svg webp)
  end

  def content_type_whitelist
    /image\//
  end

  version :thumbnail do
    process resize_to_limit: [82, 82]
  end

  version :small do
    process resize_to_limit: [240, 80]
  end

  version :medium do
    process resize_to_limit: [380, 250]
  end

  version :webp do
    process convert_to_webp: [{ quality: 60, method: 5 }]
    process resize_to_fit: [600, 600]

    def full_filename(file)
      build_webp_full_filename file, version_name
    end
  end

  private

  def convert_to_webp(options = {})
    # Build path for new file
    webp_path = "#{ path }.webp"

    # Encode (convert) image to webp format with passed options
    WebP.encode(path, webp_path, options)

    @filename = webp_path.split('/').pop

    @file = CarrierWave::SanitizedFile.new tempfile: webp_path,
                                           filename: webp_path,
                                           content_type: 'image/webp'
  end

  def build_webp_full_filename(filename, version_name)
    return "#{ version_name }_#{ filename }" if filename.split('.').last == 'webp'

    "#{ version_name }_#{ filename }.webp"
  end
end

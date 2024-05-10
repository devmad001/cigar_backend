class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  def store_dir
    "uploads/#{ model.class.to_s.underscore }/#{ model.id }"
  end

  def extension_allowlist
    %w(jpg jpeg gif png pdf svg webp)
  end

  # def content_type_allowlist
  #   /image\//
  # end

  version :thumbnail do
    process resize_to_limit: [82, 82]
  end

  version :medium do
    process resize_to_limit: [180, 180]
  end
end

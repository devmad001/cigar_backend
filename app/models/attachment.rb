# == Schema Information
#
# Table name: attachments
#
#  id              :bigint           not null, primary key
#  attachable_type :string
#  attachable_id   :bigint
#  attachment      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  position        :integer
#
class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true

  validates :attachment, presence: true
  validates :position, presence: true, if: ->{ self.attachable_type == 'Article' }

  mount_uploader :attachment, AttachmentUploader

  def attachment_type
    return if self['attachment'].blank?
    self['attachment'] =~ /^.+?\.([^.]+)$/
    case $1
    when *%w(mov mp4)
      :video
    when *%w(jpg jpeg png)
      :image
    else
      nil
    end
  end

  def video?
    self.attachment_type == :video
  end

  def image?
    self.attachment_type == :image
  end

  def self.sql_build_file_path
    "'#{ Rails.env.production? ? s3_base_path : '' }/uploads/attachment/' || id || '/' || attachment"
  end
end

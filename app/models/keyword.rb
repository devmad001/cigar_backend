# == Schema Information
#
# Table name: keywords
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Keyword < ApplicationRecord
  validates :title, presence: true
  # validates :title, uniqueness: {
  #   case_sensitive: false,
  #   message: proc { "^#{ I18n.t('errors.keyword_exist') }" }
  # }, if: ->{ self.title.present? }

  def self.find_or_create(title)
    keyword = self.find_by(title: title)
    keyword ||= self.create title: title
    keyword
  end
end

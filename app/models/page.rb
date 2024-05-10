# == Schema Information
#
# Table name: pages
#
#  id         :bigint           not null, primary key
#  page_type  :integer
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Page < ApplicationRecord
  enum page_type: %i(privacy_policy terms_and_conditions cookie_policy)

  validates :content, presence: true
  validates :page_type, uniqueness: {
    case_sensitive: false, message: I18n.t('errors.page_uniq')
  }

  def title
    self.page_type&.humanize
  end
end

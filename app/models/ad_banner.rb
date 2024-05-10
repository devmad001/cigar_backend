# == Schema Information
#
# Table name: ad_banners
#
#  id         :bigint           not null, primary key
#  title      :string
#  body       :text
#  ad_type    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AdBanner < ApplicationRecord
  enum ad_type: %i(square_250x250 horizontal_728x90 horizontal_300x250 horizontal_300x50 horizontal_468x60 vertical_160x600 vertical_300x600)

  validates :title, :body, :ad_type, presence: true
end

# == Schema Information
#
# Table name: system_settings
#
#  id          :bigint           not null, primary key
#  sitemap     :string
#  sitemap_arx :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class SystemSetting < ApplicationRecord
  def self.single
    self.first_or_create
  end
end

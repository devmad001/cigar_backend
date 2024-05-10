# == Schema Information
#
# Table name: sessions
#
#  id         :uuid             not null, primary key
#  code       :string
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Session < ApplicationRecord
  ONLINE_INTERVAL = 1.minute

  belongs_to :user

  def self.destroy_expired
    where('updated_at < ?', 1.hour.ago).destroy_all
  end

  def update_lifetime!
    return true if self.updated_at > (ONLINE_INTERVAL.to_i / 2).seconds.ago
    self.update_attribute :updated_at, Time.now
  end
end

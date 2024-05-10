# == Schema Information
#
# Table name: guests
#
#  id         :bigint           not null, primary key
#  ip         :string
#  location   :string
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Guest < ApplicationRecord
  belongs_to :user, optional: true
  has_many :actions, dependent: :destroy

  def name
    [self.user&.full_name, self.ip].compact_blank.first
  end

  def self.find_or_create_guest(ip:, user_id:)
    user = User.find_by id: user_id

    if user.present?
      guest = self.find_by user_id: user.id
      guest.update_attribute :ip, ip if guest && ip.present? && guest.ip != ip
    end

    guest = self.find_by ip: :ip if guest.blank? && ip.present?
    guest ||= self.create user_id: user&.id, ip: ip
    guest
  end
end

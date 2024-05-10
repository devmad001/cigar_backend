# == Schema Information
#
# Table name: favorites
#
#  id         :bigint           not null, primary key
#  product_id :bigint
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :product_id, uniqueness: { scope: :user_id }
end

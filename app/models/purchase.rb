# == Schema Information
#
# Table name: purchases
#
#  id         :bigint           not null, primary key
#  product_id :bigint
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Purchase < ApplicationRecord
  belongs_to :user
  belongs_to :product
end

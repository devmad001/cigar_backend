# == Schema Information
#
# Table name: reviews
#
#  id            :bigint           not null, primary key
#  title         :string
#  body          :text
#  rating        :integer
#  user_id       :bigint
#  product_id    :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  reviewer_name :string
#  review_date   :datetime
#
class Review < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :product

  validates :rating, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5,
  }, if: ->{ self.rating.present? }
end

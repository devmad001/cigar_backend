# == Schema Information
#
# Table name: coupons
#
#  id             :bigint           not null, primary key
#  coupon_id      :string
#  name           :string
#  description    :string
#  start_date     :datetime
#  end_date       :datetime
#  resource_id    :bigint
#  status         :integer
#  code           :string
#  exclusive      :boolean
#  coupon_type    :integer
#  percentage_off :float
#  dollar_off     :float
#  response       :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Coupon < ApplicationRecord
  belongs_to :resource, optional: true

  enum coupon_type: %i(text)
  # enum status: %i()
end

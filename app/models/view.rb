# == Schema Information
#
# Table name: views
#
#  id          :bigint           not null, primary key
#  product_id  :bigint
#  user_id     :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entity_type :string
#  entity_id   :bigint
#  guest_id    :bigint
#
class View < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :guest, optional: true
  belongs_to :entity, polymorphic: true
end

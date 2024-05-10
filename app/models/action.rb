# == Schema Information
#
# Table name: actions
#
#  id          :bigint           not null, primary key
#  action_type :integer
#  guest_id    :bigint
#  entity_type :string
#  entity_id   :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
class Action < ApplicationRecord
  belongs_to :guest
  belongs_to :entity, polymorphic: true, optional: true

  enum action_type: %i[view_product view_category move_to_seller search_request]

  def self.register!(**attributes)
    action_attributes = attributes

    case attributes[:entity].class.name
    when 'Product'
      action_attributes[:action_type] = :view_product
    when 'Category'
      action_attributes[:action_type] = :view_category
    end if action_attributes[:action_type].blank?

    Action.create **action_attributes
  end
end

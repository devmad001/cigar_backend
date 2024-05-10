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
require "test_helper"

class ActionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

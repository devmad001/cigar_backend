# == Schema Information
#
# Table name: answers
#
#  id         :bigint           not null, primary key
#  title      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Answer < ApplicationRecord
  validates :title, :body, presence: true
  validates :title, length: { in: 6..150 }, if: ->{ self.title.present? }
end

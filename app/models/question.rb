# == Schema Information
#
# Table name: questions
#
#  id         :bigint           not null, primary key
#  full_name  :string
#  email      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Question < ApplicationRecord
  validates :full_name, :email, presence: true
  validates :full_name, length: { in: 6..48 }, if: ->{ self.full_name.present? }
  validates :email,
            format: {
              with: EMAIL_REGEXP,
              message: proc { "^#{ I18n.t('errors.email_incorrect') }" }
            },
            length: { in: 6..48 }, if: ->{ self.email.present? }
end

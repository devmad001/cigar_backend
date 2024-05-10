# == Schema Information
#
# Table name: newsletter_subscribers
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class NewsletterSubscriber < ApplicationRecord
  validates :email, presence: true

  validates :email,
            uniqueness: {
              case_sensitive: false,
              message: proc { "^#{ I18n.t('errors.email_subscribed') }" }
            },
            format: {
              with: EMAIL_REGEXP,
              message: proc { "^#{ I18n.t('errors.email_incorrect') }" }
            },
            length: { in: 6..48 }, presence: true, if: ->{ self.email.present? }
end

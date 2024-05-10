# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  encrypted_password :string
#  salt               :string
#  email              :string
#  phone_number       :string
#  token              :string
#  full_name          :string
#  state              :string
#  city               :string
#  address            :string
#  social_id          :string
#  social_type        :integer
#  confirmed          :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  newsletter         :boolean          default(TRUE)
#  image              :string
#  self_update        :boolean          default(FALSE)
#
class User < ApplicationRecord
  %i(sessions reviews views purchases favorites).each do |relation|
    has_many relation, dependent: :destroy
  end

  attr_accessor :password, :password_confirmation, :remove_image

  enum social_type: %i(facebook google)

  mount_uploader :image, ImageUploader

  validates :email, :phone_number, presence: true, unless: ->{ self.social? }

  validates :email,
            uniqueness: {
              case_sensitive: false,
              message: proc { "^#{ I18n.t('errors.email_registered') }" }
            },
            format: {
              with: EMAIL_REGEXP,
              message: proc { "^#{ I18n.t('errors.email_incorrect') }" }
            },
            length: { in: 6..48 }, presence: true, if: ->{ self.email.present? }

  validates :phone_number,
            uniqueness: {
              case_sensitive: false,
              message: proc { "^#{ I18n.t('errors.phone_number_registered') }" }
            },
            format: { with: /\+\d{9,}/, message: proc { I18n.t('errors.is_incorrect') } },
            if: ->{ self.phone_number.present? }

  validates :full_name, presence: true
  validates :full_name, length: { in: 4..48 }, if: ->{ self.full_name.present? }

  before_save :encrypt_password
  before_validation :downcase_email
  after_validation :check_remove_image

  validates :password, presence: true, confirmation: true, length: { in: 6..48 }, if: :validate_password?
  validates :password_confirmation, presence: true, if: :validate_password?

  after_create :notify

  def image
    super if self['image'].present?
  end

  def social?
    self.social_type.present?
  end

  def info
    profile = self.attributes
                  .symbolize_keys
                  .slice(
                    :id,
                    :email,
                    :phone_number,
                    :full_name,
                    :state,
                    :city,
                    :address,
                    :newsletter,
                    :created_at,
                    :updated_at
                  )

    profile[:avatar_image] = self.image if self['image'].present?
    profile[:social_type] = self.social_type if self.social_type.present?
    profile
  end

  def authenticate?(password)
    self.encrypted_password == self.encrypt(password)
  end

  def forgot_password
    self.update(
      token: self.generate_uniq_token(:token)
    )
    UserMailer.reset_password(self.token, self).deliver_now
  rescue => e
    self.errors.add :base, e.message
  end

  def reset_password!(_password, _password_confirmation)
    return self.errors.add :password, I18n.t('errors.blank') if _password.blank?
    self.update password: _password,
                password_confirmation: _password_confirmation,
                token: nil
  end

  def change_password!(_current_password, _password, _password_confirmation)
    if self.authenticate? _current_password
      return self.errors.add :password, I18n.t('errors.blank') if _password.blank?
      self.password = _password
      self.password_confirmation = _password_confirmation
      self.save
    else
      self.errors.add :current_password, "^#{ I18n.t('errors.incorrect_current_password') }"
    end
  end

  def change_email!(_password, _email)
    if self.authenticate? _password
      self.email = _email
      self.save
    else
      self.errors.add :password, "^#{ I18n.t('errors.incorrect_current_password') }"
    end
  end

  def change_phone_number!(_password, _phone_number, _code)
    if self.authenticate? _password
      self.phone_number = _phone_number
      self.code = _code
      self.save
    else
      self.errors.add :password, "^#{ I18n.t('errors.incorrect_current_password') }"
    end
  end

  def newsletter!
    self.newsletter = !self.newsletter
    self.save
  end

  def encrypt(string)
    secure_hash("#{ string }--#{ self.salt }")
  end

  private

  def validate_password?
    self.new_record? && self.social_type.blank? ||
        self.password.present? || self.password_confirmation.present?
  end

  def downcase_email
    self.email.downcase! if self.email.present?
  end

  def encrypt_password
    self.salt = make_salt if self.salt.blank?
    self.encrypted_password = self.encrypt(self.password) if self.password.present?
  end

  def check_remove_image
    if self.remove_image.is_a?(String) && !%w(false 0 no not).include?(self.remove_image.downcase) &&
        ![nil, 0, false].include?(self.remove_image)
      self.remove_image!
    end
  end

  def make_salt
    SecureRandom.hex 32
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest string
  end

  def notify
    UserMailer.successful_registration(self).deliver_now
  rescue => e
  end
end

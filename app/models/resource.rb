# == Schema Information
#
# Table name: resources
#
#  id         :bigint           not null, primary key
#  name       :string
#  url        :string
#  host       :string
#  show       :boolean          default(TRUE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Resource < ApplicationRecord
  validates :name, :url, presence: true
  validates :name, length: { in: 2..150 }, if: ->{ self.name.present? }
  validates :host, uniqueness: true, if: ->{ self.host.present? }

  validate :validate_url

  before_validation :set_host, if: ->{ self.url.present? }

  after_save do
    Product.where("link ILIKE '%#{ self.host }%'").update_all resource_id: self.id
  end

  has_many :products

  private

  def set_host
    self.host = URI.parse(self.url)&.host
  rescue => e
    self.errors.add :url, I18n.t('errors.is_incorrect')
  end

  def validate_url
    if self.url.present? && self.host.blank?
      self.errors.add :url, I18n.t('errors.is_incorrect')
    end
  end
end

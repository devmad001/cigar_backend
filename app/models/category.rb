# == Schema Information
#
# Table name: categories
#
#  id             :bigint           not null, primary key
#  title          :string
#  image          :string
#  description    :text
#  category_id    :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  position       :integer
#  original_title :string
#  show           :boolean          default(TRUE)
#
class Category < ApplicationRecord
  belongs_to :category, optional: true

  has_many :products, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :actions, as: :entity, dependent: :delete_all

  acts_as_list
  mount_uploader :image, ImageUploader

  validates :title, presence: true

  before_validation { self.original_title ||= self.title }

  scope :categories, ->{ self.where(category_id: nil) }
  scope :subcategories, ->{ self.where.not(category_id: nil) }

  def category?
    self.category_id.blank?
  end

  def subcategory?
    self.category_id.present?
  end
end

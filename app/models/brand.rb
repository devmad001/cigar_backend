# == Schema Information
#
# Table name: brands
#
#  id         :bigint           not null, primary key
#  name       :string
#  image      :string
#  active     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Brand < ApplicationRecord
  validates :name, :image, presence: true
  validates :name, uniqueness: true, if: ->{ self.name.present? }

  mount_uploader :image, ImageUploader

  def self.available_names
    Product
        .where(category: Category.find_by(original_title: 'Cigars'))
        .select(:brand_name)
        .distinct
        .pluck(:brand_name) - self.pluck(:name)
  end
end

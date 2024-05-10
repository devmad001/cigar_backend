# == Schema Information
#
# Table name: products
#
#  id              :bigint           not null, primary key
#  name            :string
#  title           :string
#  description     :text
#  price           :integer          default(0)
#  old_price       :integer          default(0)
#  discount        :string
#  rating          :string
#  brand_name      :string
#  link            :string
#  click_link      :string
#  specifications  :jsonb
#  seller          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  category_id     :bigint
#  product_type    :string
#  refreshed_at    :datetime
#  country_fltr    :string
#  strength_fltr   :string
#  wrapper_fltr    :string
#  shape_fltr      :string
#  length_fltr     :string
#  resource_id     :bigint
#  int_rating      :integer
#  length_id       :bigint
#  brand_id        :bigint
#  product_type_id :bigint
#  country_id      :bigint
#  strength_id     :bigint
#  wrapper_id      :bigint
#  shape_id        :bigint
#  status          :integer          default("active")
#
class Product < ApplicationRecord
  FILTERS_COLUMNS = {
    brand_name: :brand_id,
    product_type: :product_type_id,
    country_fltr: :country_id,
    strength_fltr: :strength_id,
    wrapper_fltr: :wrapper_id,
    shape_fltr: :shape_id,
  }.freeze

  belongs_to :category, optional: true
  belongs_to :resource, optional: true

  FILTERS_COLUMNS.values.each do |key|
    belongs_to key, class_name: Keyword.name, optional: true
  end

  has_many :reviews, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :views, as: :entity, dependent: :delete_all
  has_many :actions, as: :entity, dependent: :delete_all

  accepts_nested_attributes_for :attachments, :reviews, allow_destroy: true

  enum status: %i(active inactive)

  validates :link, presence: true, uniqueness: true

  before_validation on: :create do
    self.refreshed_at ||= DateTime.now
  end

  before_save do
    self.int_rating = self.rating.to_i if self.rating.present?
    self.old_price = nil if self.price == self.old_price
    self.discount = nil if self.discount == 0

    FILTERS_COLUMNS.each do |filter_column, id_column|
      filter_column_str = filter_column.to_s

      if self[filter_column_str].present?
        self[id_column.to_s] ||= Keyword.find_or_create(self[filter_column_str])&.id
      end
    end
  end

  before_save :set_resource

  scope :available_products, -> do
    self
        .active
        .where(
          '(products.resource_id IS NULL OR NOT EXISTS (SELECT FROM resources WHERE '\
            'resources.id = products.resource_id AND resources.show IS NOT TRUE))'
        )
        .where('products.price IS NOT NULL AND products.price > 0')
        .where('(products.title IS NOT NULL OR products.name IS NOT NULL)')
  end

  scope :inactive, -> do
    self
        .where(
          'products.price IS NULL OR products.price <= 0 OR (products.title IS NULL AND products.name IS NULL)'
        )
        .update_all(status: :inactive)

    self.where(
      '(products.resource_id IS NOT NULL AND EXISTS (SELECT FROM resources WHERE '\
        'resources.id = products.resource_id AND resources.show IS NOT TRUE)) OR '\
        'products.status != :active_status',
      active_status: Product.statuses[:active]
    )
  end

  def site_link
    return if ENV['FRONT_HOST'].blank?
    URI.join(ENV['FRONT_HOST'], '/product/', self.slug).to_s
  end

  def self.searchable_language
    'english'
  end

  def self.searchable_columns
    %i(title)
  end

  private

  def set_resource
    return if self.link.blank?

    host = URI.parse(self.link)&.host
    self.resource ||= Resource.find_by host: host if self.resource_id.blank?
    self.resource ||= Resource.create host: host, name: self.seller if self.resource_id.blank?
  rescue => e

  end
end

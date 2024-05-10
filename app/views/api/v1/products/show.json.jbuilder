@product = ProductsQueries.find_product @product.id, @current_user

json.(@product,
  :id,
  :name,
  :title,
  :description,
  :category_id,
  :link,
  :click_link,
  :price,
  :old_price,
  :rating,
  :link,
  :click_link,
  :seller,
  :slug,
  :created_at,
  :updated_at
)

json.views @product['views']
json.(@product, :purchased_at, :favorite) if @current_user.present?

json.specifications do
  if  @product['category'].present? && @product['category']['original_title'] == 'Cigars'
    valid_options = %w(type shape strength ring length country wrapper filler binder)
    specs = {}
    valid_options.each do |s|
      specs[s] = @product.specifications[s] if @product.specifications[s].present?
      specs['wrapper'] = @product.specifications['wrapper_origin'] if s == 'wrapper' && @product.specifications['wrapper_origin'].present?
      specs['country'] = @product.specifications['orgin'] if s == 'country' && @product.specifications['orgin'].present?
      specs['country'] = @product.specifications['origin'] if s == 'country' && @product.specifications['origin'].present?
    end
    json.merge! specs
  else
    json.merge! @product.specifications
  end
end

json.category do
  json.merge! @product['category'].except('image')
  json.image Category.build_image(
    @product['category']['id'],
    @product['category']['image']
  ) if @product['category']['image'].present?
end if @product['category'].present?

if @product['attachments'].present?
  _attachments = @product['attachments'].map do |attachment|
    Attachment.build_image attachment['id'], attachment['attachment']
  end

  json.attachments _attachments
end

json.reviews @product['reviews']

json.products @products.each do |product|
  json.(product,
    :id,
    :title,
    :price,
    :old_price,
    :discount,
    :rating,
    :seller,
    :slug
  )

  json.image_url product['image_url'] if product['image_url'].present?
end
json.suggestions @suggestions

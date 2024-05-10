json.categories @categories.each do |category|
  json.(category,
    :id,
    :title,
    :category_id
  )
  json.products category['products'] if category['products'].present?
end

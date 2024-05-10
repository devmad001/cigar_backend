json.categories @categories.each do |category|
  json.(category,
    :id,
    :title,
    :description,
    :category_id,
    :position,
    :products_count,
    :category_id,
    :slug,
    :created_at,
    :updated_at
  )

  json.image category.image if category['image'].present?

  json.subcategories category['subcategories'].each do |subcategory|
    subcategory.symbolize_keys!

    json.(subcategory,
      :id,
      :title,
      :description,
      :category_id,
      :position
    )

    json.slug Category.slug subcategory[:id], subcategory[:title]
    json.image Category.build_image(subcategory[:id], subcategory[:image]) if subcategory[:image].present?
  end if category['subcategories'].present?
end
json.count @count

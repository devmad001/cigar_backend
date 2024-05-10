json.brands @brands.each do |brand|
  json.(brand,
    :id,
    :name,
    :active,
    :created_at,
    :updated_at
  )

  json.image brand.image if brand['image'].present?
end

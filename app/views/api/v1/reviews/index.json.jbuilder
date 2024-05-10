json.reviews @reviews.each do |review|
  json.(review,
    :id,
    :title,
    :body,
    :rating,
    :created_at,
    :updated_at,
    :reviewer_name,
    :review_date
  )

  %w(user product).each do |key|
    json.set! key, review[key] if review[key].present?
  end
end
json.count @count

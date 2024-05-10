@review = ReviewsQueries.find_review @review.id

json.(@review,
  :id,
  :title,
  :body,
  :rating,
  :created_at,
  :updated_at
)

%w(user product).each do |key|
  json.set! key, @review[key] if @review[key].present?
end

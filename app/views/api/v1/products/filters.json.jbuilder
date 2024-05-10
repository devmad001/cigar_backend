json.filters do
  #length removed

  %i(price ring).each do |key|
    json.set! key do
      json.type :range
      json.values @filters[key]
    end if @filters[key].present? && @filters[key].values.compact.present?
  end

  json.rating @filters[:rating] if @filters[:rating].present?

  {
    brand: :brands_filter,
    seller: :seller_filter,
    origin: :origin_filter,
    strength: :strength_filter,
    country: :country_filter,
    wrapper: :wrapper_filter,
    type: :type_filter,
    accessories_type: :accessories_type_filter,
    shape: :shape_filter
  }.each do |k, v|
    json.set! k do
      json.type 'array'
      json.values @filters[v]
    end if @filters[v].present?
  end
end

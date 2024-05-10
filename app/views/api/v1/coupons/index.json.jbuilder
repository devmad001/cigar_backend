json.coupons @coupons.each do |coupon|
json.(coupon,
    :id,
    :name,
    :description,
    :start_date,
    :end_date,
    :resource_id,
    :status,
    :code,
    :exclusive,
    :coupon_type,
    :percentage_off,
    :dollar_off,
    :created_at,
    :updated_at
  )
end
json.count @count

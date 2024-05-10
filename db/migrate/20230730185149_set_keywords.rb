class SetKeywords < ActiveRecord::Migration[6.1]
  def change
    {
      brand_name: :brand_id,
      product_type: :product_type_id,
      country_fltr: :country_id,
      strength_fltr: :strength_id,
      wrapper_fltr: :wrapper_id,
      shape_fltr: :shape_id,
    }.each do |filter_key, id_key|
      Product.where.not(filter_key => nil).select(filter_key).distinct.pluck(filter_key).compact.uniq.each do |i|
        keyword = Keyword.find_or_create i
        Product.where(filter_key => i).update_all id_key => keyword.id
      end
    end
  end
end

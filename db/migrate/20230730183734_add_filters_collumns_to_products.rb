class AddFiltersCollumnsToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :brand
    add_reference :products, :product_type
    add_reference :products, :country
    add_reference :products, :strength
    add_reference :products, :wrapper
    add_reference :products, :shape
  end
end

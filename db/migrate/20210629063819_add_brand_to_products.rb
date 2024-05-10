class AddBrandToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :brand
  end
end

class RemoveBrandIdFromProducts < ActiveRecord::Migration[6.1]
  def change
    remove_index :products, :brand_id, name: 'index_products_on_brand_id'

    remove_column :products, :brand_id
  end
end

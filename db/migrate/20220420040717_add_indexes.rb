class AddIndexes < ActiveRecord::Migration[6.1]
  def change
    %i(brand_name seller product_type).each do |column_name|
      add_index :products, column_name
    end
  end
end

class AddCategoryToProduct < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :category
  end
end

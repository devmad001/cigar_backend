class AddPositionFieldToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :position, :integer
    Category.order(:created_at).each.with_index(1) do |item, index|
      item.update_column :position, index
    end
  end
end

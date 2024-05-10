class AddShowToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :show, :boolean, default: true
  end
end

class AddOriginalTitleToCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :original_title, :string

    Category.update_all('original_title = title')
  end
end

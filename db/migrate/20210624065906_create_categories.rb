class CreateCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :categories do |t|
      t.string :title
      t.string :image
      t.text :description
      t.references :category
      t.timestamps
    end
  end
end

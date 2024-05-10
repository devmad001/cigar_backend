class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :title
      t.text :description
      t.string :price
      t.string :old_price
      t.string :discount
      t.string :rating
      t.string :brand
      t.string :link
      t.string :click_link
      t.jsonb :specifications
      t.string :seller

      t.timestamps
    end
  end
end

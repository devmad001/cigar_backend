class AddProductLinkIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :products, :link, unique: true
  end
end

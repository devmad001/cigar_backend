class AddRefreshedAtToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :refreshed_at, :datetime
  end
end

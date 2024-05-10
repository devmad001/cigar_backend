class ChangePriceFields < ActiveRecord::Migration[6.1]
  def change
    change_column :products, :price, :integer,  using: 'price::integer', default: 0
    change_column :products, :old_price, :integer,  using: 'old_price::integer', default: 0
  end
end

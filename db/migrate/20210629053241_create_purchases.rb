class CreatePurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :purchases do |t|
      t.references :product
      t.references :user
      t.timestamps
    end
  end
end

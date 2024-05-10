class RemoveBrands < ActiveRecord::Migration[6.1]
  def change
    drop_table :brands
  end
end

class RenameProductsBrandField < ActiveRecord::Migration[6.1]
  def self.up
    rename_column :products, :brand, :brand_name
  end

  def self.down
    rename_column :products, :brand_name, :brand
  end
end

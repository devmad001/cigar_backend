class AddFilterFiledsToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :country_fltr, :string
    add_column :products, :strength_fltr, :string
    add_column :products, :wrapper_fltr, :string
    add_column :products, :shape_fltr, :string
    add_column :products, :length_fltr, :string
    add_index :products, :country_fltr
    add_index :products, :strength_fltr
    add_index :products, :wrapper_fltr
    add_index :products, :shape_fltr
    add_index :products, :length_fltr

    Product.find_each do |product|
      specs = product.specifications
      fields = {}
      fields[:country_fltr] = specs.try(:[], 'origin') || specs.try(:[], 'country')
      fields[:strength_fltr] = specs.try(:[], 'strength')
      fields[:wrapper_fltr] = specs.try(:[], 'wrapper_type') || specs.try(:[], 'wrapper') || specs.try(:[], 'wrapper_origin')
      fields[:shape_fltr] = specs.try(:[], 'shape') || specs.try(:[], 'shapes')
      fields[:length_fltr] = specs.try(:[], 'length')
      product.update(fields)
    end
  end
end

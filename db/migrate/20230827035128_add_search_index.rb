class AddSearchIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :products, :title, using: :gist, opclass: :gist_trgm_ops
  end
end

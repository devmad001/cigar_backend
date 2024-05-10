class ChangeViews < ActiveRecord::Migration[6.1]
  def change
    add_reference :views, :entity, polymorphic: true

    View.update_all  "entity_id = views.product_id, entity_type = 'Product'"
  end
end

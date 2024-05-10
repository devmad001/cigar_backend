class AddDescriptionToActions < ActiveRecord::Migration[6.1]
  def change
    add_column :actions, :description, :text
  end
end

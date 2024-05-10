class RenameColumnNameForGuests < ActiveRecord::Migration[6.1]
  def change
    remove_index :guests, name: 'index_guests_on_users_id'
    rename_column :guests, :users_id, :user_id
    add_index :guests, :user_id
  end
end

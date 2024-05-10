class AddSelfUpdateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :self_update, :boolean, default: false
  end
end

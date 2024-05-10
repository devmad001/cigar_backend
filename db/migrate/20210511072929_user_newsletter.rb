class UserNewsletter < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :newsletter, :boolean, default: true
  end
end

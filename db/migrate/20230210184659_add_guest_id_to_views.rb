class AddGuestIdToViews < ActiveRecord::Migration[6.1]
  def change
    add_reference :views, :guest
  end
end

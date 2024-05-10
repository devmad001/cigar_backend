class AddPositionToAttachments < ActiveRecord::Migration[6.1]
  def change
    add_column :attachments, :position, :integer
  end
end

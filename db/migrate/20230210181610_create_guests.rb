class CreateGuests < ActiveRecord::Migration[6.1]
  def change
    create_table :guests do |t|
      t.string :ip
      t.string :location
      t.references :users

      t.timestamps
    end
  end
end

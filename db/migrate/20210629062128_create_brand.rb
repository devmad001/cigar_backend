class CreateBrand < ActiveRecord::Migration[6.1]
  def change
    create_table :brands do |t|
      t.string :title
      t.timestamps
    end
  end
end

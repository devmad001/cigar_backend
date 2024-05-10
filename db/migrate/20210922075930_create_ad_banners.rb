class CreateAdBanners < ActiveRecord::Migration[6.1]
  def change
    create_table :ad_banners do |t|
      t.string :title
      t.text :body
      t.integer :ad_type

      t.timestamps
    end
  end
end

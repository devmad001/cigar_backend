class CreateSystemSettings < ActiveRecord::Migration[6.1]
  def change
    create_table :system_settings do |t|
      t.string :sitemap
      t.string :sitemap_arx
      t.timestamps
    end
  end
end

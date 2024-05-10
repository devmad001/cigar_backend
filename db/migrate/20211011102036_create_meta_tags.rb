class CreateMetaTags < ActiveRecord::Migration[6.1]
  def change
    create_table :meta_tags do |t|
      t.string :title
      t.text :description
      t.integer :page_type
      t.timestamps
    end
  end
end

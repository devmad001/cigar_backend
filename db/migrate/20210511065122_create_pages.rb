class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.integer :page_type
      t.text :content
      t.timestamps
    end
  end
end

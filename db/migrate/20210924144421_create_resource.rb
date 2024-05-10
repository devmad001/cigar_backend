class CreateResource < ActiveRecord::Migration[6.1]
  def change
    create_table :resources do |t|
      t.string :name
      t.string :url
      t.string :host
      t.boolean :show, default: true
      t.timestamps
    end
  end
end

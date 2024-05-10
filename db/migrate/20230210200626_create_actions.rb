class CreateActions < ActiveRecord::Migration[6.1]
  def change
    create_table :actions do |t|
      t.integer :action_type
      t.references :guest
      t.references :entity, polymorphic: true

      t.timestamps
    end
  end
end

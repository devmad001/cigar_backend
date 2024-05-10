class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :full_name
      t.string :email
      t.text :body
      t.timestamps
    end
  end
end

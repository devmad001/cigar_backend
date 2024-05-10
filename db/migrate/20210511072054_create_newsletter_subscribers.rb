class CreateNewsletterSubscribers < ActiveRecord::Migration[6.1]
  def change
    create_table :newsletter_subscribers do |t|
      t.string :email
      t.timestamps
    end
  end
end

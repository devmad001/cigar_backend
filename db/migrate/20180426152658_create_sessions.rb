class CreateSessions < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'

    create_table :sessions, id: :uuid do |t|
      t.string :code
      t.references :user
      t.timestamps
    end
  end
end

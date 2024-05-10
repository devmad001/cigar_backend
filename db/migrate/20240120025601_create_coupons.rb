class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons do |t|
      t.string :coupon_id
      t.string :name
      t.string :description
      t.datetime :start_date
      t.datetime :end_date
      t.references :resource
      t.integer :status
      t.string :code
      t.boolean :exclusive
      t.integer :coupon_type
      t.float :percentage_off
      t.float :dollar_off
      t.jsonb :response
      t.timestamps
    end
  end
end

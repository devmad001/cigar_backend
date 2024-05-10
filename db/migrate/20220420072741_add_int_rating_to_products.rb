class AddIntRatingToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :int_rating, :integer

    5.times do |i|
      Product.where("rating LIKE '#{ i + 1 }%'").update_all int_rating: i + 1
    end
  end
end

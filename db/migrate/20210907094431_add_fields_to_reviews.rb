class AddFieldsToReviews < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :reviewer_name, :string
    add_column :reviews, :review_date, :datetime
  end
end

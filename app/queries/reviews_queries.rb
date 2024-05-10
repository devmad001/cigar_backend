class ReviewsQueries < BaseQueries
  class << self
    def reviews_list(params, current_user:, count: false)
      reviews = Review.arel_table

      query = reviews
                  .group(reviews[:id])

      self.datetime_filters params, query, reviews, %i(created_at updated_at)
      self.text_filters params, query, %i(title body)
      self.eq_filters params, query, reviews, %i(user_id product_id)

      unless count
        reviews_project query

        sort_column = params[:sort_column]&.to_sym
        sort_column = :created_at unless %i(title body user_id product_id created_at updated_at).include?(sort_column)

        query.order(
          reviews[sort_column].try self.sort_type(params[:sort_type]) || :desc
        )
      end

      query
    end

    def reviews_project(query)
      query.project(
        'reviews.*',
        as(select_as_hash(
          select table: 'users',
                 columns: 'id, full_name',
                 conditions: 'reviews.user_id = users.id'
        ), 'user'),
        as(select_as_hash(
          select table: 'products',
                 columns: 'id, title, name',
                 conditions: 'reviews.product_id = products.id'
        ), 'product')
      )
    end

    def find_review(id)
      reviews = Review.arel_table

      query = reviews
                  .group(reviews[:id])
                  .where(reviews[:id].eq id)
                  .take(1)

      reviews_project query

      Review.find_by_sql(query.to_sql).first
    end
  end
end

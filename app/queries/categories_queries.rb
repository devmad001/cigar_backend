class CategoriesQueries < BaseQueries
  class << self
    def categories_list(params, current_user:, count: false)
      categories = Category.arel_table

      query = categories
                  .group(categories[:id])
                  .where(categories[:show].eq true)

      self.datetime_filters params, query, categories, %i(created_at updated_at)
      self.text_filters params, query, %i(title description)
      self.eq_filters params, query, categories, %i(category_id)

      unless count
        category_project query

        sort_column = params[:sort_column]&.to_sym
        sort_column = :position unless %i(title category_id created_at updated_at).include?(sort_column)

        query.order(
          categories[sort_column].try self.sort_type(params[:sort_type]) || :asc
        )
      end

      query
    end

    def category_project(query)
      query.project(
        'categories.*',
        as(select_as_array(
          'SELECT * FROM categories AS subcategories WHERE '\
            'subcategories.category_id = categories.id ORDER BY subcategories.title'
        ), :subcategories),
        '(SELECT count(id) FROM products WHERE products.category_id = categories.id OR '\
          'products.category_id IN (SELECT id FROM categories AS subcategories WHERE '\
          'subcategories.category_id = categories.id)) AS products_count'
      )
    end

    def find_category(id)
      categories = Category.arel_table

      query = categories
                  .group(categories[:id])
                  .where(categories[:id].eq id)
                  .take(1)

      category_project query

      Category.find_by_sql(query.to_sql).first
    end
  end
end

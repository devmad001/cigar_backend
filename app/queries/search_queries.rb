class SearchQueries < BaseQueries
  class << self
    def categories_list(params, current_user:, count: false)
      categories = Category.arel_table

      query = categories.group(categories[:id])
      self.datetime_filters params, query, categories, %i(created_at updated_at)
      self.eq_filters params, query, categories, %i(id)

      unless count
        query.project(
          'categories.*',
          as(select_as_array(select(
            table: 'products',
            columns: "#{ columns_list(current_user) }",
            conditions: "products.category_id = categories.id #{ products_condition(params) } LIMIT 6"
          )), :products),
        )
      end

      query
    end

    def product_image_url
      as(wrap(select(
        table: :attachments,
        columns: as(Attachment.sql_build_file_path, :image_url),
        conditions: "attachable_type = 'Product' AND attachable_id = products.id ORDER BY id LIMIT 1"
      )), :image_url)
    end

    private

    def columns_list(current_user)
      columns = %w(
        id name title description price old_price discount rating brand_name
        link click_link specifications seller created_at updated_at category_id
      )
      columns << product_image_url
      columns << "#{ favorite_query current_user } AS favorite" if current_user.present?
      columns.join(', ')
    end

    def favorite_query(current_user)
      ProductsQueries.favorite_query current_user
    end

    def products_condition(params)
      condition = ''
      condition += "AND products.title ILIKE '%#{ sql_sanitize params[:title] }%'" if params[:title].present?
      condition += " AND products.seller IN #{ array_param(params[:seller]) }" if params[:seller].present?
      condition += " AND products.price >= #{ params[:price_from].to_i }" if params[:price_from].present?
      condition += " AND products.price <= #{ params[:price_to].to_i }" if params[:price_to].present?
      condition += " AND #{ rating_query(params[:rating]) }" if params[:rating].present?
      condition += " ORDER BY #{ order(params) }"
      condition
    end

    def rating_query(params)
      ProductsQueries.rating_query params
    end

    def order(params)
      sort_column = params[:sort_column]&.to_sym
      sort_column = :title unless %i(purchases price created_at).include?(sort_column)

      order = "#{ sort_column } #{ self.sort_type(params[:sort_type]) || :asc }"

      order = '(SELECT count(*) FROM purchases WHERE product_id = products.id) '\
                "#{ self.sort_type(params[:sort_type]) || :desc }" if sort_column == :purchases

      order
    end
  end
end

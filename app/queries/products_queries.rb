class ProductsQueries < BaseQueries
  class << self
    def products_list(params, current_user:, count: false, project: nil, order: true)
      products = Product.arel_table

      query = products
                  .group(products[:id])
                  .where(Arel.sql(excepted_resources_query))
                  .where(Arel.sql('(products.title IS NOT NULL OR products.name IS NOT NULL)'))
                  .where(Arel.sql('products.price IS NOT NULL AND products.price > 0'))
                  .where(products[:status].eq Product.statuses[:active])

      q = prepare_ts_query sql_sanitize(params[:q])

      if q.present?
        ids = MeilisearchClient.products_result_ids(q, limit: 10000)
        query.where(products[:id].in ids) if ids.present?
      end

      self.datetime_filters params, query, products, %i(created_at updated_at)
      self.text_filters params, query, %i(name description)
      self.eq_filters params, query, products, %i(category_id)

      query.where(Arel.sql(
        "products.price >= #{ params[:price_from].to_i }"
      )) if params[:price_from].present?

      query.where(Arel.sql(
        "products.price <= #{ params[:price_to].to_i }"
      )) if params[:price_to].present?

      query.where(Arel.sql(
        "products.brand_id IN #{ keywords_query params[:brand] }"
      )) if params[:brand].present?

      query.where(Arel.sql(
        "products.resource_id IN (SELECT id FROM resources WHERE resources.name ILIKE ANY (#{ any_param params[:seller] }))"
      )) if params[:seller].present?

      query.where(Arel.sql(
        'products.category_id IN (SELECT id FROM categories WHERE '\
          "categories.title IN #{ array_param(params[:type]) })"
      )) if params[:type].present?

      countries = params[:origin] || params[:country]
      query.where(Arel.sql(
        "products.country_id IN #{ keywords_query countries }"
      )) if countries

      query.where(Arel.sql(
        "products.strength_id IN #{ keywords_query params[:strength] }"
      )) if params[:strength].present?

      query.where(Arel.sql(
        "products.wrapper_id IN #{ keywords_query params[:wrapper] }"
      )) if params[:wrapper].present?

      shape = serialise_array params[:shape]
      query.where(Arel.sql(
        "(products.shape_id IN #{ keywords_query shape } OR "\
          "products.title ILIKE ANY (#{ any_param shape.map { |i| "%#{ i }%" } }))"
      )) if shape.present?

      query.where(Arel.sql(
        "products.product_type_id IN #{ keywords_query params[:accessories_type] }"
      )) if params[:accessories_type].present?

      query.where(Arel.sql(rating_query(params[:rating]))) if params[:rating].present?

      query.where(Arel.sql(
        "products.specifications->>'length' >= '#{ params[:length_from].to_f }'"
      )) if params[:length_from].present?

      query.where(Arel.sql(
        "products.specifications->>'length' <= '#{ params[:length_to].to_f }'"
      )) if params[:length_to].present?

      query.where(Arel.sql(
        "products.specifications->>'ring' >= '#{ params[:ring_from].to_f }'"
      )) if params[:ring_from].present?

      query.where(Arel.sql(
        "products.specifications->>'ring' <= '#{ params[:ring_to].to_f }'"
      )) if params[:ring_to].present?

      query.where(Arel.sql(
        best_sellers_query
      )) if self.boolean?(params[:best_sellers]) && self.true?(params[:best_sellers])

      query.where(Arel.sql(
        "(products.old_price IS NOT NULL OR products.discount IS NOT NULL)"
      )).order('random()') if self.boolean?(params[:hot_sale]) && !self.false?(params[:hot_sale])

      query.where(Arel.sql(
        "#{ self.false?(params[:daily_deals]) ? 'NOT ' : '' }#{ daily_deals_query }"
      )) if self.boolean?(params[:daily_deals])

      if current_user.present?
        query.where(Arel.sql(
          "#{ self.false?(params[:favorite]) ? 'NOT ' : '' }#{ favorite_query current_user }"
        )) if self.boolean?(params[:favorite])

        query.where(Arel.sql(
          "#{ self.false?(params[:purchased]) ? 'NOT ' : '' }EXISTS (#{ purchase_query current_user })"
        )) if self.boolean?(params[:purchased])

        query.where(Arel.sql(
          "#{ self.false?(params[:viewed]) ? 'NOT ' : '' } EXISTS (#{ views_query current_user })"
        )) if self.boolean?(params[:viewed])

        query.where(Arel.sql(
          'products.category_id IN (SELECT DISTINCT category_id FROM products AS p '\
            "WHERE #{ excepted_resources_query } AND p.id IN "\
            "(SELECT entity_id FROM (SELECT DISTINCT entity_id, created_at "\
            "FROM views WHERE views.entity_type = 'Product' AND "\
            "views.user_id = #{ current_user.id } ORDER BY views.created_at DESC) AS v LIMIT 3))"
        )) if self.boolean?(params[:recommendations]) && self.true?(params[:recommendations])
      end

      unless count
        if project.present?
          query.project project
        else
          products_project query, current_user
        end

        query.project()

        if order
          sort_column = params[:sort_column]&.to_sym
          sort_column ||= :match_rank if q.present?
          sort_column = :created_at unless %i(name title category_id purchases purchased_at price viewed_at favorite_at created_at updated_at random suggestion match_rank).include?(sort_column)
          sort_column = :created_at if current_user.blank? && %i(purchased_at viewed_at).include?(sort_column)

          case sort_column
          when :purchases
            query.order(
              '(SELECT count(*) FROM purchases WHERE product_id = products.id) '\
                "#{ self.sort_type(params[:sort_type]) || :desc }"
            )
          when :purchased_at
            query.order(
              '(SELECT created_at FROM purchases WHERE product_id = products.id AND '\
                "purchases.user_id = #{ current_user.id } ORDER BY created_at DESC LIMIT 1) "\
                "#{ self.sort_type(params[:sort_type]) || :desc }"
            )
          when :viewed_at
            query.order(
              "(#{ views_query current_user, 'created_at' } ORDER BY created_at DESC LIMIT 1) "\
              "#{ self.sort_type(params[:sort_type]) || :desc }"
            )
          when :favorite_at
            query.order(
              '(SELECT created_at FROM favorites WHERE product_id = products.id AND '\
                "favorites.user_id = #{ current_user.id } ORDER BY created_at DESC LIMIT 1) "\
                "#{ self.sort_type(params[:sort_type]) || :desc }"
            )
          when :random
            query.order('random()')
          when :suggestion
            query.order("array_position(array[#{ @ids }], products.id::int) #{ params[:sort_type] || 'ASC' }") if @ids.present?
          when :match_rank
            query.order("strict_word_similarity(products.title, '#{ q }') #{ params[:sort_type] || 'DESC' }")
          else
            query.order(
              products[sort_column].try self.sort_type(params[:sort_type]) || :asc
            )
          end
        end
      end

      query
    end

    def filters(params, current_user:, default: true)
      cat = Category.find_by id: params[:category_id] if params[:category_id].present?
      filters_params = params.except(:controller, :action, :format, :per_page, :page)
      filters_params = filters_params.except(:category_id) if cat.present? && cat.title == 'Best Sellers'

      if default && filters_params.except(:category_id).blank? && cat
        category_default_filters = default_filters[cat.id.to_s]
        return category_default_filters if category_default_filters.present?
      end

      select_columns = Product::FILTERS_COLUMNS.values + %i(resource_id category_id rating int_rating price id)
      select_columns << "specifications->>'ring' AS ring"

      sql_query = ProductsQueries.products_list(
        filters_params,
        current_user: current_user,
        project: select_columns.join(', '),
        order: false
      ).to_sql

      filters_project = [
        as(wrap(select_as_hash(
          'SELECT ' +
          [
            "'rating' AS type",
            *{ one: 1, two: 2, three: 3, four: 4, five: 5 }.map do |k, v|
              "count(fp.rating) filter (WHERE fp.int_rating = #{ v }) AS #{ k }"
            end
          ].join(',')
        )), :rating),
        as(select_as_hash(
          "SELECT min(fp.price) AS min, max(fp.price) AS max"
        ), :price),
        filter_item(
          :seller,
          column_name: :resource_id,
          keywords_query: products_query(filters_params, current_user: current_user, select_columns: :resource_id)
        )
      ]

      if cat.present?
        filters_project << filter_item(:brand, column_name: :brand_id, _alias: :brands_filter, keywords_query: products_query(filters_params, current_user: current_user, select_columns: :brand_id))
        category_title = cat.original_title&.strip

        if ['Cigars', 'Machine Made Cigars', 'Tobacco'].include?(category_title)
          filters_project << filter_item(
            :strength,
            column_name: :strength_id,
            keywords_query: products_query(filters_params, current_user: current_user, select_columns: :strength_id)
          )

          filters_project += [
            filter_item(
              :country,
              column_name: :country_id,
              keywords_query: products_query(filters_params, current_user: current_user, select_columns: :country_id)
            ),
            filter_item(
              :wrapper,
              column_name: :wrapper_id,
              keywords_query: products_query(filters_params, current_user: current_user, select_columns: :wrapper_id)
            ),
            filter_item(
              :shape,
              column_name: :shape_id,
              keywords_query: products_query(filters_params, current_user: current_user, select_columns: :shape_id)
            )
          ] unless category_title == 'Tobacco'
        end

        case category_title
        when 'Cigars'
          filters_project << as(select_as_hash(
            "SELECT min(ring) AS min, max(ring) AS max"
          ), :ring)
        when 'Best Sellers'
          filters_project << filter_item(
            :type,
            column_name: :category_id,
            _alias: :type_filter,
            keywords_query: products_query(filters_params, current_user: current_user, select_columns: :category_id)
          )
        when 'Tobacco'
          filters_project << filter_item(
            :country,
            column_name: :country_id,
            _alias: :origin_filter,
            keywords_query: products_query(filters_params, current_user: current_user, select_columns: :country_id)
          )
        when 'Accessories'
          filters_project << filter_item(
            :accessories_type,
            column_name: :product_type_id,
            _alias: :accessories_type_filter,
            keywords_query: products_query(filters_params, current_user: current_user, select_columns: :product_type_id)
          ) if cat.category?
        end
      end

      Category.find_by_sql(
        "SELECT #{ filters_project.join(', ') } FROM (#{ sql_query }) AS fp LIMIT 1"
      ).first
    end

    def products_project(query, current_user)
      query.project(
        'products.*',
        '(SELECT count(id) FROM views WHERE products.id = views.entity_id AND '\
          "views.entity_type = 'Product') AS views",
        as(select_as_hash(
          select table: 'attachments',
                 columns: 'id, attachment',
                 conditions: "attachable_type = 'Product' AND attachable_id = products.id ORDER BY id ASC LIMIT 1"
        ), :attachment),
        as(select_as_hash(
          select table: 'categories',
                 columns: '*',
                 conditions: 'categories.id = products.category_id'
        ), :category),
      )

      query.project(
        "(#{ purchase_query current_user, 'created_at' } ORDER BY purchases.created_at DESC LIMIT 1) AS purchased_at",
        as(favorite_query(current_user), :favorite)
      ) if current_user.present?
    end

    def find_product(id, current_user)
      products = Product.arel_table

      query = products
                  .group(products[:id])
                  .where(products[:id].eq id)
                  .take(1)

      products_project query, current_user

      query.project(
        as(select_as_array(
          select table: 'attachments',
                 columns: 'id, attachment',
                 conditions: "attachable_type = 'Product' AND attachable_id = products.id ORDER BY id ASC"
        ), :attachments),
        as(select_as_array(
             select table: 'reviews',
                    columns: '*',
                    conditions: 'product_id = products.id ORDER BY id ASC'
        ), :reviews)
      )

      result = Product.find_by_sql(query.to_sql).first

      result.attributes.keys.each do |key|
        if key.include?('_filter')
          result.attributes[key].sort_by { |i| i['name'] }
        end
      end

      result
    end

    def shape_options(params, current_user:)
      sql_query = ProductsQueries
                      .products_list(
                        params,
                        current_user: current_user,
                        project: 'products.id, products.shape_id'
                      )
                      .to_sql

      Product.find_by_sql(
        'SELECT DISTINCT(shape_id) AS id, (SELECT title FROM keywords WHERE keywords.id = fp.shape_id) AS name, '\
          "count(fp.shape_id) filter (WHERE fp.shape_id = shape_id) AS count FROM (#{ sql_query }) AS fp "\
          'WHERE fp.shape_id IS NOT NULL GROUP BY shape_id ORDER BY count DESC LIMIT 10'
      )
    end

    def rating_query(params)
      "products.int_rating IN (#{ serialise_array(params).map(&:to_i).join(',') })"
    end

    def favorite_query(current_user)
      'EXISTS (SELECT FROM favorites WHERE products.id = favorites.product_id AND '\
        "favorites.user_id = #{ current_user&.id })"
    end

    def default_filters
      if @default_filters.blank?
        @default_filters = {}

        Category.select(:id).all.pluck(:id).each do |id|
          @default_filters[id.to_s] = filters({ category_id: id }, current_user: nil, default: false)
        end
      end

      @default_filters
    end

    private

    def products_query(filters_params, current_user:, select_columns: nil)
      project = select_columns
      project = project.join(', ') if project.is_a?(Array)

      ProductsQueries.products_list(
        filters_params,
        current_user: current_user,
        project: project || 'products.*',
        order: false
      ).to_sql
    end

    def purchase_query(current_user, columns = '')
      "SELECT #{ columns } FROM purchases WHERE products.id = purchases.product_id AND "\
        "purchases.user_id = #{ current_user&.id }"
    end

    def daily_deals_query(columns = '')
      "EXISTS (SELECT #{ columns } FROM purchases WHERE products.id = purchases.product_id AND "\
        'purchases.created_at::date = now()::date)'
    end

    def best_sellers_query
      "EXISTS (SELECT FROM purchases WHERE purchases.product_id = products.id)"
    end

    def filter_item(filter, column_name: nil, _alias: nil, keywords_query: nil)
      case column_name&.to_sym
      when :resource_id
        keyword_table = :resources
        keyword_column = :name
      when :category_id
        keyword_table = :categories
        keyword_column = :title
      else
        keyword_table = :keywords
        keyword_column = :title
      end

      as(select_as_array(
        "SELECT coalesce(array_length( array_positions(array_agg(fp.#{ column_name }), "\
          'uniq_keywords.keyword_id), 1),0) AS count, '\
        "(SELECT #{ keyword_column } FROM #{ keyword_table } WHERE "\
          "#{ keyword_table }.id = uniq_keywords.keyword_id) AS name FROM "\
        "(SELECT DISTINCT fpt.#{ column_name } AS keyword_id FROM #{ keywords_query.present? ? wrap(keywords_query) : 'products' } AS fpt "\
          "WHERE fpt.#{ column_name } IS NOT NULL) AS uniq_keywords"
      ), _alias || "#{ filter }_filter")
    end

    def views_query(current_user, columns = '')
      "SELECT #{ columns } FROM views WHERE views.user_id = #{ current_user.id } AND "\
        "views.entity_id = products.id AND views.entity_type = 'Product'"
    end

    def excepted_resources_query
      '(products.resource_id IS NULL OR NOT EXISTS (SELECT FROM resources WHERE '\
        'resources.id = products.resource_id AND resources.show IS NOT TRUE))'
    end

    def any_param(params)
      jsonb_array serialise_array(params)
    end

    def keywords_query(params)
      "(SELECT id FROM keywords WHERE keywords.title ILIKE ANY (#{ any_param params }))"
    end
  end
end

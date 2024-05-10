class ArticlesQueries < BaseQueries
  class << self
    def articles_list(params, count: false, current_user:)
      articles = Article.arel_table

      query = articles
                  .group(articles[:id])

      datetime_fields = %i(created_at updated_at)
      text_fields = %i(title body)

      self.datetime_filters params, query, articles, datetime_fields
      self.text_filters params, query, text_fields
      enum_filter query, articles, Article, :article_type, params[:article_type]

      query.where(Arel.sql(
        "#{ self.false?(params[:viewed]) ? 'NOT ' : '' }EXISTS "\
          "(#{ views_query current_user: current_user, columns: 'id' })"
      )) if current_user.present? && self.boolean?(params[:viewed])

      unless count
        articles_project query, current_user

        custom_fields = %i(views last_day_views last_week_views last_month_views)

        sort_column = params[:sort_column]&.to_sym
        unless (datetime_fields + text_fields + custom_fields + %i(article_type)).include?(sort_column)
          sort_column = :created_at
        end

        case sort_column
        when *custom_fields
          query.order(
            "(#{ views_query interval(sort_column) }) #{ self.sort_type(params[:sort_type]) || :desc }"
          )
        else
          query.order(
            articles[sort_column].try self.sort_type(params[:sort_type]) || :desc
          )
        end
      end

      query
    end

    def articles_project(query, current_user)
      query.project(
        'articles.*',
        "(#{ views_query  }) AS views",
        as(select_as_array(select(
          table: 'attachments',
          columns: "id, position, #{ Attachment.sql_build_file_path } AS url, " +
                    select_datetime_fields(%i(created_at updated_at)).join(', '),
          conditions: "attachments.attachable_id = articles.id AND attachments.attachable_type = 'Article'"
        )), :attachments)
      )

      if current_user.present?
        query.project(
          "EXISTS (#{ views_query current_user: current_user, columns: 'id' }) AS viewed"
        )
      end
    end

    def find_article(id, current_user)
      articles = Article.arel_table

      query = articles
                  .group(articles[:id])
                  .where(articles[:id].eq id)
                  .take(1)

      articles_project query, current_user

      Article.find_by_sql(query.to_sql).first
    end

    private

    def views_query(interval = nil, current_user: nil, columns: 'count(id)')
      conditions = "views.entity_id = articles.id AND views.entity_type = 'Article'"
      conditions += " AND created_at >= '#{ interval.ago }'" if interval.is_a?(ActiveSupport::Duration)
      conditions += " AND views.user_id = #{ current_user.id }" if current_user.present?
      select table: 'views', columns: columns, conditions: conditions
    end

    def interval(key)
      case key
      when :last_day_views
        1.day
      when :last_week_views
        1.week
      when :last_month_views
        1.month
      else
        nil
      end
    end
  end
end

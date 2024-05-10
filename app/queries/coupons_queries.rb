class CouponsQueries < BaseQueries
  class << self
    def coupons_list(params, current_user:, count: false)
      coupons = Coupon.arel_table

      query = coupons.group(coupons[:id])

      datetime_columns = %i(start_date end_date created_at updated_at)
      text_columns = %i(name description coupon_id code)
      eq_columns = %i(resource_id)
      enum_columns = %i(status coupon_type)

      self.datetime_filters params, query, coupons, datetime_columns
      self.text_filters params, query, text_columns
      self.eq_filters params, query, coupons, eq_columns

      enum_columns.each do |key|
        self.enum_filter query, coupons, Coupon, key, params[key]
      end

      unless count
        query.project('coupons.*')

        sort_column = params[:sort_column]&.to_sym

        unless (datetime_columns + text_columns + eq_columns + eq_columns + enum_columns).include?(sort_column)
          sort_column = :name
        end

        query.order(coupons[sort_column].try self.sort_type(params[:sort_type]) || :asc)
      end

      query
    end
  end
end

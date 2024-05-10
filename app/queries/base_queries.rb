class BaseQueries
  class << self
    include BooleanHelper

    CHARS = ('a'..'z').to_a

    def sort_type(_sort_type)
      _sort_type if %i(asc desc).include?(_sort_type&.to_sym)
    end

    def parse_datetime(value)
      case value.class.name
      when 'Date'
        value.to_datetime
      when 'Time'
        value.to_datetime
      when 'DateTime'
        value
      when 'String'
        value.strip!
        DateTime.parse value if value.present?
      when 'Integer', 'Number', 'Bignum', 'Fixnum'
        Time.at(value).to_datetime
      end
    rescue => e

    end

    def datetime_filters(params, query, relation, fields)
      fields.each do |field|
        from_date = parse_datetime params["#{ field }_from".to_sym]
        to_date = parse_datetime params["#{ field }_to".to_sym]
        query.where(relation[field].gteq from_date) if from_date.present?
        query.where(relation[field].lteq to_date) if to_date.present?
      end
    end

    def text_filters(params, query, fields, relation = nil)
      fields.each do |field|
        next unless params[field].present?
        
        if relation
          query.where(relation[field].matches("%#{ sql_sanitize params[field] }%"))
        else
          query.where(Arel.sql("#{ field } ILIKE '%#{ sql_sanitize params[field] }%'"))
        end
      end
    end

    def eq_filters(params, query, relation, fields)
      fields.each do |field|
        query.where(relation[field].eq params[field]) if params[field].present?
      end
    end

    def enum_filter(query, relation, model, column, param)
      return if param.blank?
      options = param.is_a?(Array) ? param : serialise_array(param)
      return if options.blank?
      values = model&.try(column.to_s.pluralize)&.symbolize_keys&.slice(*options&.map(&:to_sym)).values
      return if values.blank?
      query.where(relation[column].in values)
    end

    def serialise_array(value, separator = ',')
      return value if value.is_a?(Array)
      sanitize_array value.split(/\s*#{ separator&.strip }\s*/) if value.is_a?(String)
    end

    def array_param(params, separator = ',')
      sql_array serialise_array(params, separator)
    end

    def select(table:, columns: nil, conditions:)
      "SELECT #{ columns } FROM #{ table } WHERE #{ conditions }"
    end

    def sql_array(array)
      "(#{ array.map { |i| i.is_a?(String) ? "'#{ i }'" : i }.join ', ' })" if array.is_a?(Array)
    end

    def select_as_array(query)
      _tmp_name = tmp_name
      "(SELECT array_to_json(array_agg(row_to_json(#{ _tmp_name }))) FROM (#{ query }) #{ _tmp_name })"
    end

    def select_as_hash(query)
      _tmp_name = tmp_name
      "(SELECT row_to_json(#{ _tmp_name }) FROM (#{ query }) #{ _tmp_name })"
    end

    def array_agg(query)
      "ARRAY_AGG(#{ query })"
    end

    def tmp_name
      res = ''
      5.times { res += CHARS.sample }
      res
    end

    def enum_select(model, column)
      "(string_to_array('#{ model.try(column.to_s.pluralize).keys.join ',' }', ','))[#{ column } + 1]"
    end

    def enums_select(model, columns)
      columns&.map do |column|
        "#{ enum_select model, column } AS #{ column }"
      end
    end

    def sql_case(*args)
      cases = args.last
      return unless cases.is_a?(Hash)
      else_value = nil
      sql_str = 'CASE '
      cases.each do |condition, value|
        if condition.to_s.downcase.strip == 'else'
          else_value = value
        else
          sql_str += " WHEN #{ condition } THEN #{ value }"
        end
      end
      sql_str += " ELSE #{ else_value }" if else_value.present?
      sql_str += ' END'
      sql_str
    end

    def coalesce(*args)
      "COALESCE(#{ args.join(', ') })"
    end

    def as(query, alias_name)
      "#{ query } AS #{ alias_name }"
    end

    def wrap(query)
      "(#{ query })"
    end

    def correct_datetime(field, as: nil)
      _alias = as || field
      "(SELECT to_char(#{ field }, 'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"')) AS #{ _alias }"
    end

    def select_datetime_fields(fields)
      fields.map { |field| correct_datetime field }
    end

    def interpolate(sql, *args)
      params = args.last

      return sql if params.blank? || !params.is_a?(Hash)

      sql = sql.clone

      params.each do |key, value|
        _value = value.is_a?(String) || value.is_a?(Symbol) ? "\"#{ value }\"" : value
        sql.gsub!(/(:#{ key })/, _value.to_s)
      end

      sql
    end

    def sql_sanitize(str)
      return str unless str.is_a?(String)
      new_str = str.clone

      new_str.scan(/'+/).to_a.each do |i|
        new_str.gsub!(i, i * 2) if i.length % 2 > 0
      end

      new_str
    end

    def exists(query)
      "EXISTS (#{ query })"
    end

    def jsonb_array(array)
      "array['#{ sanitize_array(array).join("','") }']" if array.is_a?(Array)
    end

    def sanitize_array(array)
      array.map { |i| sql_sanitize i } if array.is_a?(Array)
    end

    def prepare_ts_query(q)
      return unless q.is_a?(String)
      q.gsub(/\s+/, ' & ')
    end
  end
end

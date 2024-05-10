require 'roo'

class XlsxParser
  class << self
    def parse(path_to_file, sheet_name)
      xlsx = Roo::Spreadsheet.open path_to_file
      result = {}
      key = nil
      collection = []

      xlsx.sheet(sheet_name).each_with_index do |row, i|
        next if i.zero?
        data = row.compact
        if data.blank?
          if result[key].present?
            result[key] = (result[key] + collection).uniq
          else
            result[key] = collection&.uniq
          end
          collection = []
          key = nil
        else
          key = data.last if data.count > 1
          collection << data.first
        end
      end

      result
    end

    def format(collection)
      puts '['
      collection.each do |key, values|
        puts key&.include?("'") ? "  \"#{ key }\" => [" : "'#{ key }' => ["
        values.compact.each do |i|
          puts i.include?("'") ? "    \"#{ i }\"," : "    '#{ i }',"
        end
        puts '  ],'
      end
      puts ']'
    end
  end
end

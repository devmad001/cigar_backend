class AttributeService
  class << self
    def select_name(_name, collection)
      return unless _name.is_a?(String)
      _prepared_name = _name.gsub(/(\s| )+/, ' ').strip.downcase
      _correct_name = collection.find do |value, names|
        value.downcase == _prepared_name ||
            names.map { |i| i&.downcase&.gsub(';', ',') }&.include?(_prepared_name&.gsub(';', ','))
      end&.first

      unless _correct_name
        _first_phrase = _prepared_name&.split(/[;,]/)&.first
        _correct_name ||= _first_phrase if collection[_prepared_name&.split(/[;,]/)&.first].present?
      end

      _correct_name || _prepared_name
    end
  end
end

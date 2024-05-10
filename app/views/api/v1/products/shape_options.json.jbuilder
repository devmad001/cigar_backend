json.options @options.each do |option|
  json.(option, :name, :count)
end

json.answers @answers.each do |answer|
  json.(answer, :id, :title, :body, :created_at, :updated_at)
end
json.count @count

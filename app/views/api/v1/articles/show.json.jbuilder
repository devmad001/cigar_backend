@article = ArticlesQueries.find_article @article.id, @current_user

json.(@article,
  :id,
  :title,
  :views,
  :article_type,
  :slug,
  :created_at,
  :updated_at
)
json.body @article&.compile_body

if @current_user.present?
  json.(@article, :viewed)
end

json.image @article.image if @article['image'].present?
json.attachments @article['attachments'] if @article['attachments'].present?

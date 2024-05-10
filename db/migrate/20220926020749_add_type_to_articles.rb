class AddTypeToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :article_type, :integer
    Article.update_all article_type: 0
  end
end

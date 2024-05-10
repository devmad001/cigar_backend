class Api::V1::ArticlesController < Api::V1::BaseController
  skip_before_action :authenticate
  before_action :init, except: %i(index)

  def index
    list Article,
         ArticlesQueries,
         :articles_list,
         current_user: current_user
  end

  def show
    View.create user: current_user, entity: @article
  end

  def view
    save_record View.new(user: current_user, entity: @article)
  end

  private

  def init
    @article = Article.find permited_parameter[:id]
  end
end

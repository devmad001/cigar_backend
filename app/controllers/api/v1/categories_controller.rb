class Api::V1::CategoriesController < Api::V1::BaseController
  skip_before_action :authenticate
  before_action :init, only: %i(show)

  def index
    list Category,
         CategoriesQueries,
         :categories_list,
         current_user: current_user
  end

  def show
  end

  private

  def init
    @category = Category.find permited_parameter[:id]
  end
end

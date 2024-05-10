class Api::V1::ReviewsController < Api::V1::BaseController
  skip_before_action :authenticate, only: %i(index show)
  before_action :init, only: %i(update destroy)

  def index
    list Review,
         ReviewsQueries,
         :reviews_list,
         current_user: current_user
  end

  def show
    @review = Review.find permited_parameter[:id]
  end

  def create
    @review = current_user.reviews.new review_params
    save_record @review, render: 'show'
  end

  def update
    @review.assign_attributes review_params
    save_record @review, render: 'show'
  end

  def destroy
    @review.destroy
    render_ok
  end

  private

  def init
    @review = Review.find_by! id: permited_parameter[:id],
                              user_id: current_user.id
  end

  def review_params
    params.permit :title, :body, :rating, :product_id
  end
end

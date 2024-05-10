class Api::V1::ProductsController < Api::V1::BaseController
  skip_before_action :authenticate, only: %i(index buy show filters search_results suggestions shape_options)
  before_action :init, only: %i(show buy save remove remove_purchase)
  before_action :category, only: %i(index search_results)

  def index
    if search_query.present?
      create_user_action! @category,
                          action_type: :search_request,
                          description: "Search '#{ search_query }' in category #{ @category&.title }"
    else
      create_user_action! @category
    end if @category.present?

    list Product,
         ProductsQueries,
         :products_list,
         current_user: current_user
  end

  def suggestions
    query = BaseQueries.sql_sanitize permited_parameter[:q]
    result = MeilisearchClient
                 .search_products(query, limit: 10)
                 .deep_symbolize_keys
                 .dig(:hits)

    if result.present?
      @suggestions = result.map { |i| i.slice(:id, :title) }

      @products = Product
                      .select(
                        'products.*',
                        SearchQueries.product_image_url
                      )
                      .where(id: result.map { |i| i[:id] }.uniq)
                      .limit(5)
    else
      @suggestions = []
      @products = []
    end
  end

  def search_results
    create_user_action! @category,
                        action_type: :search_request,
                        description: "Search '#{ search_query }' in all categories"

    list Category,
         SearchQueries,
         :categories_list,
         current_user: current_user
  end

  def filters
    @filters = ProductsQueries.filters params, current_user: current_user
  end

  def shape_options
    @options = ProductsQueries.shape_options params, current_user: current_user
  end

  def show
    create_user_action! @product
    View.create entity: @product, user: current_user
  end

  def buy
    create_user_action! @product, action_type: :move_to_seller

    if current_user
      @purchase = Purchase.find_by product: @product, user: current_user

      if @purchase.blank? || @purchase.created_at < 6.hours.ago
        Purchase.create product: @product, user: current_user
      end
    end

    render_ok
  end

  def remove_purchase
    @purchase = Purchase.find_by(product: @product, user: current_user)&.destroy
    render_ok
  end

  def save
    @favorite = Favorite.new product: @product, user: current_user
    save_record @favorite
  end

  def remove
    Favorite.find_by(product: @product, user: current_user)&.destroy
    render_ok
  end

  private

  def init
    @product ||= Product.find permited_parameter[:id]
  end

  def category
    @category ||= Category.find_by id: params[:category_id]
  end

  def create_user_action!(target, **special_attributes)
    guest = Guest.find_or_create_guest(user_id: current_user&.id, ip: request.remote_ip)
    Action.register! entity: target, guest: guest, **special_attributes
  end

  def search_query
    @search_query ||= params.permit(:title, :q).values.compact_blank.first
  end
end

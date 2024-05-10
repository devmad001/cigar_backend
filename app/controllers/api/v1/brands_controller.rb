class Api::V1::BrandsController < Api::V1::BaseController
  skip_before_action :authenticate

  def index
    @brands = Brand.where(active: true).order(name: :asc)
  end
end

class Api::V1::CouponsController < Api::V1::BaseController
  skip_before_action :authenticate, only: %i(index show)

  def index
    list Coupon,
         CouponsQueries,
         :coupons_list,
         current_user: current_user
  end

  def show
    @coupon = Coupon.find permited_parameter[:id]
  end
end

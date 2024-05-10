class Api::V1::AdBannersController < Api::V1::BaseController
  skip_before_action :authenticate

  def get_banner
    @banner = AdBanner.where(ad_type: params[:ad_type]).order('random()').first
  end
end

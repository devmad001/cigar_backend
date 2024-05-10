class AscendService
  class << self
    include LogHelper

    PRODUCTS = 'product'
    COUPONS = 'coupon'

    def list(url)
      result =  RestClient.get url
      body = JSON.parse(result).with_indifferent_access
      body&.dig(:meta, :status, :code) == 200 ? body : nil
    rescue => e
      log_error self.name, __method__, e.message
    end

    def format_url(type:, page: 1)
      url = "https://api.pepperjamnetwork.com/20120402/publisher/creative/#{ type }?apiKey=#{ ENV['ASCEND_API_KEY'] }&format=json"
      url += "&page=#{ page }" if page > 1
      url
    end

    def products(page = 1)
      url = format_url type: PRODUCTS, page: page
      list url
    end

    def coupons(page = 1)
      url = format_url type: COUPONS, page: page
      list url
    end
  end
end

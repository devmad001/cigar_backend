# API docs
# https://developers.cj.com

class CjService
  STORES = {
    # 'www.dd8shop.com' => '5654236',
    # 'vapordna.com' => '4882569',
    'www.thompsoncigar.com' => '2965991',
    'www.gothamcigars.com' => '3982297',
    monthlyclub: '2397857',
    'www.famous-smoke.com' => '6240744',
    month_clubs: '818719',
    'www.cigarsinternational.com' => '5359174'
    # airvape: '5146556'
  }.freeze

  class << self
    include LogHelper
    include HttpRequestHelper

    def list(resource_pid)
      return if resource_pid.blank?

      options = {
        headers: {
          'Authorization' => "Bearer #{ ENV['CJ_TOKEN'] }",
          'Content-Type' => 'application/json'
        },
        store_id: resource_pid
      }

      get_cj_products(options)&.dig('data')
    end

    def get_cj_products(options = {})
      url = 'https://ads.api.cj.com/query'
      body = "{products(partnerIds: [\"#{ options[:store_id] }\"], "\
              "companyId: \"#{ ENV['CJ_COMPANY_ID'] }\") "\
              "{resultList {id,title,link,linkCode(pid: \"#{ ENV['CJ_SITE_ID'] }\") {clickUrl}}}}"

      get_json url, { payload: body, headers: options[:headers], method: :post, use_proxy: false }
    rescue => e
      log_error self.name, __method__, e.message
    end
  end
end

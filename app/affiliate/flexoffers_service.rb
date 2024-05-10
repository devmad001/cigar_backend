# API docs
# https://publisherpro.flexoffers.com/DataFeeds/APIDocumentation

class FlexoffersService
  API_URL = 'https://api.flexoffers.com'

  ADV_IDS = {
    'www.cigars.com' => 230060,
    'www.jrcigars.com' => 170434
  }.freeze

  class << self
    include LogHelper
    include HttpRequestHelper

    def headers
      # https://publisherpro.flexoffers.com/DataFeeds/WebServices/APIKeys
      {
        'Accept' => 'application/json',
        'apiKey' => ENV['FLEXOFFERS_API_KEY']
      }
    end

    def use_proxy
      true
    end

    def domains
      request '/domains'
    end

    def adv_terms(adv_id)
      request('/advertisers/advertiserTerms', { query: { advertiserId: adv_id }})
    end

    def adv_apply(adv_id)
      request '/advertisers/applyAdvertiser', { query: { acceptTerms: true, advertiserId: adv_id }}, :html
    end

    def categories
      request '/categories'
    end

    # def advertisers()
    #
    # end

    def deeplink(url, adv_id)
      query = { advertiserId: adv_id, URL: url }.compact
      request '/deeplink', { query: query }
    end

    def products_advertisers(page: 1, page_size: 20, name: nil)
      query = { page: page, page_size: page_size, name: name }.compact
      request '/products/advertisers', { query: query }
    end

    def products_allcatalogs(page: 1, page_size: 20, name: nil)
      query = { page: page, page_size: page_size, name: name }.compact
      request '/products/allcatalogs', { query: query }
    end

    def products_catalogs(aid)
      request '/products/catalogs', { query: { aid: aid } }
    end

    def products_categories(cat_id: nil, cid: nil)
      query = { cat_id: cat_id, cid: cid }.compact
      request '/products/categories', { query: query }
    end

    def coupons(adv_id: nil, page: 1, page_size: 50)
      query = { advertiserId: adv_id, page: page, pageSize: page_size }.compact
      request '/coupons', { query: query }
    end

    def camelize_keys(hash)
      return {} unless hash.is_a?(Hash)
      res = {}

      hash.each do |k, v|
        res[k.to_s.camelize(:lower)] = v
      end

      res
    end

    def request(path, options = {}, accept = :json)
      %i(query payload).each do |option|
        options[option] = camelize_keys options[option] if options[option]
      end

      url = URI.join(API_URL, path).to_s

      case accept
      when :json
        get_json url, options
      else
        get_resp(url, options)&.body
      end
    end

    def host_by_id(id)
      ADV_IDS.reverse[id.to_i]
    end
  end
end

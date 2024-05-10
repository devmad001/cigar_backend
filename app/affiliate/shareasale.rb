require 'digest'
require 'time'

class Shareasale
  API_TOKEN = ENV['SAREASALE_TOKEN']
  API_SECRET = ENV['SAREASALE_SECRET']
  AFFILIATE_ID = ENV['SHARESALE_AFFILIATE_ID']
  API_VERSION = 2.3
  API_URL = 'https://api.shareasale.com'
  ACTION_VERB = 'getProducts'

  MERCHANTS = {
    'mikescigars.com' => {
      b: 821682,
      m: 63476
    },
    'www.bnbtobacco.com' => {
      b: 174741,
      m: 22265
    }
  }

  class << self
    include LogHelper
    include HttpRequestHelper

    def timestamp
      Time.now.utc.to_s.gsub('UTC', 'GMT')
    end

    def sig(_timestamp = timestamp)
      "#{ API_TOKEN }:#{ _timestamp }:#{ ACTION_VERB }:#{ API_SECRET }"
    end

    def sig_hash(_sig = sig)
      Digest::SHA256.hexdigest(_sig).upcase
    end

    def parameters(merchant_id)
      {
        affiliateID: AFFILIATE_ID,
        token: API_TOKEN,
        version: API_VERSION,
        action: ACTION_VERB,
        XMLFormat: 1,
        keyword: 'cigar',
        merchantId: merchant_id
      }
    end

    def query(_parameters = parameters)
      _parameters.to_query
    end

    def url(_query = query)
      "#{ API_URL }/x.cfm?#{ query }"
    end

    def client
      _timestamp = timestamp
      _sig = sig _timestamp
      _sig_hash = sig_hash _sig

      headers = {
        'x-ShareASale-Date' => _timestamp,
        'x-ShareASale-Authentication' => _sig_hash
      }

      get_resp url, { headers: headers, use_proxy: false }
    end

    def track_link(product_link)
      q = { u: AFFILIATE_ID, urllink: URI.encode(product_link), afftrack: '' }
              .merge(MERCHANTS[URI.parse(product_link).host.split('.')[-2]])
              .to_query

      "https://shareasale.com/r.cfm?#{ q }"
    rescue => e
      log_error self.name, __method__, e.message
    end

    def set_all!
      MERCHANTS.each do |host, v|
        resource = Resource.find_by host: host

        next if resource.blank? || !resource.show?

        params = v.merge(u: AFFILIATE_ID, afftrack: '')

        Product.where(resource_id: resource.id, click_link: [nil, '']).find_each do |product|
          puts product.id
          product.update_attribute :click_link,
                                   "https://shareasale.com/r.cfm?#{ params.merge(urllink: product.link).to_query }"
        end
      end
    end
  end
end

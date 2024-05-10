# API docs
# https://integrations.impact.com/impact-publisher/reference/overview

class ImpactLinksSetter
  include LogHelper

  ROOT_URL = 'https://api.impact.com'
  BASE_URL = "/Mediapartners/#{ ENV['IMPACT_SID'] }/"
  ACCOUNT_INFO = 'CompanyInformation'
  Campaigns = 'Campaigns'
  ADS = 'Ads'
  PER_PAGE = 1000
  ALLOWED_HOSTS = [Smokeinn.root]

  def initialize
    @authorization ||= Base64.urlsafe_encode64("#{ ENV['IMPACT_SID'] }:#{ ENV['IMPACT_TOKEN'] }")

    @headers ||= {
      'Accept' => 'application/json',
      'Authorization' => "Basic #{ @authorization }",
      'Host' => 'api.impact.com',
      'User-Agent' => 'Cigar Finder',
      'IR-Version' => 14
    }
  end

  def account_info(**options)
    request format_link(ACCOUNT_INFO, **options)
  end

  def campaigns(**options)
    request format_link(Campaigns, **options)
  end

  def ads(**options)
    request format_link(ADS, **options)
  end

  def set_click_links!
    next_page_url = format_link(ADS, page_size: 1000)

    loop do
      resp = request next_page_url

      resp[ADS]&.each do |ad|
        product_url = ad['LandingPageUrl']
        next unless ALLOWED_HOSTS.any? { |host| product_url.index(host)&.zero? }
        update_product product_url, ad['TrackingLink']
      end

      next_page_url = resp['@nextpageuri']
      break if next_page_url.blank?
    end
  end

  def format_link(path, **options)
    link = URI.join(ROOT_URL, BASE_URL, path).to_s

    query = {}

    options.each do |key, value|
      query[key.to_s.camelize] = value
    end

    query.compact!
    link += "?#{ query.to_query }" if query.present?

    link
  end

  def request(link)
    raw_resp = RestClient::Request.new(method: :get, url: link, headers: @headers).execute
    JSON.parse raw_resp
  end

  def update_product(link, click_link)
    return if link.blank? || click_link.blank? || (product = Product.find_by link: link).blank?
    product.update_attribute :click_link, click_link
  end
end

class Yotpo < BaseParser
  LATEST_WIDGET_VERSION = '2023-05-24_17-54-31'

  class << self
    def host
      'staticw2.yotpo.com'
    end

    def user_agent
      'Mozilla/5.0 (Windows NT 10.0; Win64; rv:114.0) Gecko/20100101 Firefox/114.0/Vbh4yE9bMUGkrbO'
    end

    def headers(options = {}, widget_version: nil, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:'User-Agent'] ||= user_agent
      @h[:Accept] ||= 'application/json'
      @h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @h[:'Content-type'] ||= 'application/x-www-form-urlencoded'
      @h[:DNT] ||= [0,1].sample
      @h[:Host] ||= host if host.present?
      @h[:Connection] ||= 'keep-alive'
      @h[:'Sec-Fetch-Dest'] ||= 'empty'
      @h[:'Sec-Fetch-Mode'] ||= 'cors'
      @h[:'Sec-Fetch-Site'] ||= 'cross-site'
      @h[:TE] ||= 'trailers'
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def reviews_params(pid:, app_key:, widget_version:, page: 1)
      {
        methods: [
          {
            method: 'reviews',
            params: {
              pid: pid.to_s,
              order_metadata_fields: {},
              widget_product_id: pid.to_s,
              data_source: 'default',
              page: page,
              'host-widget' => 'main_widget',
              is_mobile: false,
              pictures_per_review: 10
            }
          }
        ].to_json,
        app_key: app_key,
        is_mobile: 'false',
        widget_version: widget_version
      }
    end

    def rating_params(pid:, app_key:, widget_version:)
      {
        methods: [
          {
            method: 'bottomline',
            params: {
              pid: pid.to_s,
              link: nil,
              skip_average_score: false,
              main_widget_pid: pid.to_s,
              widget_product_id: pid.to_s
            }
          }
        ].to_json,
        app_key: app_key,
        is_mobile: 'false',
        widget_version: widget_version
      }
    end

    def rating(pid:, app_key:, widget_version: LATEST_WIDGET_VERSION, origin:)
      return if pid.blank? || app_key.blank? || origin.blank?

      url = "#{ self.root }/batch/app_key/#{ app_key }/domain_key/#{ pid }/widget/bottomline"
      _encoded_params = rating_params(pid: pid, app_key: app_key, widget_version: widget_version).to_query
      _page_headers = headers.merge 'Content-Length': _encoded_params.length, 'Cache-Control': 'max-age=0'

      resp = get_json url,
                      method: :post,
                      headers: _page_headers,
                      payload: _encoded_params

      return if resp.blank?

      html = Nokogiri::HTML resp.dig(0, 'result')

      return if html.blank?

      html.at('.sr-only')&.text&.strip&.split(/\s+/)&.first
    end

    def reviews(pid:, app_key:, widget_version: LATEST_WIDGET_VERSION, origin:, rating: true)
      return {} if pid.blank? || app_key.blank? || origin.blank?

      url = "#{ self.root }/batch/app_key/#{ app_key }/domain_key/#{ pid }/widget/reviews"
      _headers = headers.merge(Origin: origin)

      result = []
      page = 1
      rating = nil

      loop do
        _encoded_params = reviews_params(pid: pid, app_key: app_key, widget_version: widget_version, page: page).to_query
        _page_headers = _headers.merge 'Content-Length': _encoded_params.length

        resp = get_json url,
                        method: :post,
                        headers: _page_headers,
                        payload: _encoded_params

        break if resp.blank?

        html = Nokogiri::HTML resp.dig(0, 'result')

        break if html.blank?

        rating = html.at('.sr-only')&.text&.strip&.split(/\s+/)&.first if rating && page == 1
        html.css('.yotpo-review.yotpo-regular-box.yotpo-hidden.yotpo-template').remove

        html.css('.yotpo-review').each do |review|
          result << {
            rating: review.at('.yotpo-review-stars/.sr-only')&.text&.strip&.split(' ').try(:first)&.to_i,
            title: review.at('.content-title')&.text&.strip,
            body: review.at('.content-review')&.text&.strip,
            reviewer_name: review.at('.yotpo-user-name')&.text&.strip,
            review_date: parse_datetime(review.at('.yotpo-review-date')&.text&.strip, pattern: '%m/%d/%y')
          }.compact_blank
        end

        break if html.at('a.yotpo_next.yotpo-disabled').present? || html.at('.yotpo-pager').blank?
        page += 1
      end

      recursive_compact_blank! result

      { rating: rating, reviews: result }.compact_blank
    end

    def resource_pid(html)
      nokogiri_try widget_block(html), 'data-product-id'
    end

    def widget_block(html)
      html.at('.yotpo.yotpo-main-widget')
    end
  end
end

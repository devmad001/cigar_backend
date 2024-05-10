class Cigars < Parser
  PER_PAGE = 20

  class << self
    def store
      'Cigars.com'
    end

    def host
      'www.cigars.com'
    end

    def proxy
      Proxies::TorProxy.proxy_options
    end

    def browser
      @browser ||= Browser.new
    end

    def client
      browser&.browser
    end

    def client!
      @browser&.close!
      @browser = Browser.new
      @browser&.browser
    end

    def restart_client!
      Proxies::TorProxy.new_ip!
      client!
    end

    def get_resp(url, options = {}, type: :html)
      try_count = 0
      request_errors = []
      repeat = true

      while repeat && try_count < RETRY_COUNT
        begin
          client.goto url
          repeat = false
        rescue => e
          try_count += 1
          request_errors << e
          repeat = true
          restart_client!
        end
      end

      log_error url, *request_errors.map(&:message) if request_errors.present? && repeat

      case type
      when :html
        client&.html
      when :json
        client&.text
      else
        client&.html
      end unless repeat
    rescue => e
      log_error self.name, __method__, error: e.message, url: url
    end

    def get_html(url, options = {})
      resp = get_resp url, options, type: :html
      Nokogiri::HTML resp if resp.present?
    end

    def get_json(url, options = {})
      resp = get_resp url, options, type: :json
      JSON.parse resp if resp.present?
    end

    def get_image(url, options = {})
      response = Parser.get_resp url, { headers: image_headers, proxy: proxy }
      download_image url, response
    end

    def preload_images?
      true
    end

    def image_headers
      {
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language' => 'en-US,en;q=0.5',
        'Connection' => 'keep-alive',
        'Upgrade-Insecure-Requests' => 1,
        'Host' => host,
        'User-Agent' => browser&.user_agent,
        'Cookie' => browser&.cookies_str('cigars.com')
      }
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          link: 'https://www.cigars.com/cigars/handmade-cigars/'
        },
        {
          name: 'Machine Made Cigars',
          link: 'https://www.cigars.com/cigars/machine-made-cigars/'
        },
        {
          name: 'Accessories',
          link: 'https://www.cigars.com/accessories/'
        }
      ]
    end

    def brands(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      html.css('.main-brand').map do |i|
        info = {}

        info[:image] = absolute_path URI.encode(nokogiri_try(i.at('.img-container/a/img'), 'src')&.strip)
        info[:name] = i.at('.info-container/.info/.brand-name')&.text&.strip
        info[:prices] = i.at('.info-container/.info/.prices')&.text&.strip
        info[:reviews_count] = i.at('.reviews-strength/.reviews/.review-count')&.text&.strip
        info[:rating] = nokogiri_try(i.at('.reviews-strength/.reviews/.rating'), 'aria-label')&.strip
        info[:strength] = i.at('.reviews-strength/.spec-strength/.visually-hidden')&.text&.strip
        info[:url] = nokogiri_try i.at('.btn.btn-gold.shop-now'), :href
        info.compact_blank
      end.compact_blank
    end

    def list(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      html.css('.search-result-items/.item.js-main-parent').map do |i|
        absolute_path nokogiri_try(i.at('.item-full-name/a'), :href)
      end.compact_blank
    end

    def pagination(&block)
      categories_urls.map do |category|
        cat = find_category category[:name]
        category_link = category[:link]

        next if category_link.blank?

        category_link += "?sz=#{ PER_PAGE }"
        page = 0

        loop do
          products_urls = list "#{ category_link }&start=#{ page * PER_PAGE }"
          break if products_urls.blank?
          page += 1
          self.instance_exec products_urls, cat, &block if block.is_a?(Proc)
        end
      end
    end

    def each_products(type: :all, &block)
      pagination do |links, cat|
        filter_products_links(links, type: type, category: cat).each do |link|
          self.instance_exec product(link), cat, &block if block.is_a?(Proc)
        end
      end
    end

    def product(url, brand_name = nil)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      info = { link: url, brand_name: brand_name }

      info_block = html.at('.right-column.item-details')

      if info_block.present?
        info[:brand_name] ||= info_block.at('.brand-name')&.text&.strip
        info[:title] = one_line_str info_block.at('h2[itemprop="name"]')&.text&.strip
        info[:sku] = info_block.at('.product-sku')&.text&.strip
        info[:description] = info_block.at('.js-readmore-product-desc.js-item-description')&.text&.strip
        info[:price] = price_to_i info_block.at('.addtocart-jrprice.js-addtocart-jrprice')&.text || info_block.at('.price-tag')&.text
        info[:old_price] = price_to_i info_block.at('.addtocart-msrpprice')&.text
        info[:discount] = price_to_i info_block.at('.js-saving-price')&.text

        if info_block.at('button.addtocart-button--soldout').present?
          info[:status] = :inactive
        else
          info[:status] = :active
        end
      end

      html.css('.cigar-detail-item').each do |i|
        key = i.at('.detail-title')&.text&.underscore&.downcase&.gsub(/\s+/, '_')&.to_sym
        value = i.at('.detail-value')&.text&.strip
        info[key] = value if key.present? && value.present?
      end

      info[:images] = html.css('.slides/.img-thumb/img').map do |i|
        URI.encode i['data-imghires']&.strip if i['data-imghires'].present?
      end

      if (yotpo_widget = Yotpo.widget_block html).present? &&
          (pid = yotpo_widget['data-product-id']).present? &&
          (app_key = yotpo_widget['data-appkey']).present?
        reviews_attributes = Yotpo.reviews pid: pid,
                                           app_key: app_key,
                                           origin: host,
                                           widget_version: '2023-07-05_08-43-33'

        info.merge! reviews_attributes if reviews_attributes.present?
      else
        info[:rating] = html.css('.yotpo-bottomline-box-1.yotpo-stars-and-sum-reviews/.yotpo-stars/.yotpo-icon-star.rating-star').count

        html.css('.yotpo-review.yotpo-regular-box.yotpo-hidden.yotpo-template').remove

        info[:reviews] = html.css('.yotpo-review.yotpo-regular-box').map do |i|
          {
            reviewer_name: i.at('.yotpo-user-name')&.text&.strip,
            review_date: parse_datetime(i.at('.yotpo-review-date')&.text&.strip, pattern: '%m/%d/%y'),
            title: compact_spaces(i.at('.content-title')&.text&.strip),
            body: compact_spaces(i.at('.content-review')&.text&.strip),
            rating: i.css('.yotpo-icon-star.rating-star').count
          }
        end
      end

      recursive_compact_blank info
    end

    def build_attributes(details, except: [])
      _attributes = super(details.except :images)
      _attributes[:title] = [_attributes[:brand_name], _attributes[:title]].compact_blank.uniq.join(' | ')
      _attributes[:discount] = nil if _attributes[:discount]&.zero?
      _attributes[:rating] = nil if _attributes[:rating]&.zero?

      if _attributes[:old_price] && _attributes[:price] && _attributes[:old_price] == _attributes[:price]
        _attributes[:old_price] = nil
      end

      if details[:images].present? && (except.blank? || except.exclude?(:images))
        _attributes[:attachments_attributes] = details[:images].map do |img|
          { attachment: image_attempts(img, _attributes[:link]) }
        end
      end

      _attributes[:country_fltr] ||= details[:filer]
      _attributes[:wrapper_fltr] ||= details[:wrapper_type]

      canonize_fltrs! _attributes
      recursive_compact_blank _attributes
    end

    def image_attempts(img, product_link, attempts: 3)
      img_file = nil

      attempts.times do
        img_file = get_image img

        if img_file.blank?
          restart_client!
          client.goto product_link
        end

        break if img_file.present?
      end

      img_file
    end
  end
end

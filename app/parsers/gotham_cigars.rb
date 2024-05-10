class GothamCigars < Parser
  class << self
    def store
      'Gotham Cigars'
    end

    def host
      'www.gothamcigars.com'
    end

    def user_agent
      'Mozilla/5.0 (Windows NT 11.0; Win64; rv:114.0) Gecko/20100101 Firefox/114.0/4aRUgvb7Hk'
    end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:'User-Agent'] ||= user_agent
      @h[:Host] ||= host if host.present?
      @h[:Accept] ||= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      @h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @h[:Connection] ||= 'keep-alive'
      @h[:'Upgrade-Insecure-Requests'] = 1
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def reviews_headers(options = {}, &block)
      if @rh.present?
        return @rh.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @rh = options || {}
      @rh[:'User-Agent'] = user_agent
      @rh[:Host] = 'stamped.io'
      @rh[:Accept] = 'application/json, text/javascript, */*; q=0.01'
      @rh[:'Accept-Language'] = 'en-US,en;q=0.5'
      @rh[:Connection] = 'keep-alive'
      @rh[:Origin] = root
      @rh[:Referer] = 'https://stamped.io/'
      self.instance_exec @rh, &block if block.is_a?(Proc)
      @rh
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          link: 'https://www.gothamcigars.com/premium-cigars/'
        },
        {
          name: 'Machine Made Cigars',
          link: 'https://www.gothamcigars.com/machine-made-cigars/'
        },
        {
          name: 'Accessories',
          link: 'https://www.gothamcigars.com/all-accessories/'
        }
      ]
    end

    def pagination(&block)
      categories_urls.each do |category|
        cat = find_category category[:name]
        list_page_url = category[:link]

        loop do
          html = get_html list_page_url

          products_urls = html
                              .css('.product/.card/.card-body/.card-title/a')
                              .map { |i| nokogiri_try i, :href }
                              .compact_blank

          list_page_url = nokogiri_try html.at('li.pagination-item.pagination-item--next/a.pagination-link'), :href

          self.instance_exec products_urls, cat, &block if block.is_a?(Proc) && products_urls.present?

          break if list_page_url.blank?
        end
      end
    end

    def product(url)
      html = get_html url
      return if html.nil?

      info = { link: url }

      info[:title] = html.at('.productView-title')&.text&.strip

      if html.at('#tab-description').present?
        description = ''
        html.at('#tab-description').css('p').each { |p| description += p&.text&.strip if p.present? }
        info[:description] = description
      end

      info[:price] = price_to_i html.at('.price.price--withoutTax')&.text
      info[:price] ||= price_to_i html.at('span.price')&.text
      info[:old_price] = price_to_i html.at('.price.price--rrp')&.text
      info[:discount] = price_to_i html.at('.price.price--saving')&.text

      if html.at('.CV__checkout_btn_clr.btn.btn--primary.cv-checkout').present? ||
          html.at('#form-action-addToCart').present?
        info[:status] = :active
      else
        info[:status] = :inactive
      end

      #specifications
      filters = %i(length wrapper strength shape)

      html.css('.product-info-row').each do |i|
        case i.at('dt')&.text
        when 'SKU:'
          info[:name] = i.at('dd')&.text&.strip
        when 'Brand:'
          info[:brand_name] = i.at('dd')&.text&.strip
        when 'Category:'
          next
        else
          key = i.at('dt')&.text&.strip&.gsub(/\s+/, '_')&.gsub(':', '')&.underscore&.to_sym
          value = i.at('dd')&.text&.strip

          if key.present? && value.present?
            info[key] = value
            info["#{ key }_fltr".to_sym] = value if filters.include?(key)
            info[:country_fltr] = value if key == :origin
          end
        end
      end if html.css('.product-info-row').present?

      #images
      info[:images] = html
                          .css('li.productView-imageCarousel-main-item/a')
                          .map { |img| img['data-original-img'] }
                          .compact_blank

      widget = html.at('#stamped-main-widget')

      if widget.present?
        widget_data = {
          productId: widget['data-product-id'],
          productTitle: URI.escape(widget['data-name'] || ''),
          page: 1,
          apiKey: 'pubkey-4eCaASz5xl3b5ErXjI0f35R1MHXn3S',
          storeUrl: host,
          sid: 22639,
          take: 50
        }.compact_blank

        info[:reviews] = parse_reviews widget_data
        info[:rating] = calc_rating info[:reviews]
      end

      recursive_compact_blank info
    end

    private

    def parse_reviews(data)
      return unless data.is_a?(Hash)

      url = 'https://stamped.io/api/widget'
      result = []
      page = 1

      loop do
        data[:page] = page
        item_url = "#{ url }?#{ data.to_query }"
        resp = get_json item_url, headers: reviews_headers

        break if resp.blank? || resp['widget'].blank?

        Nokogiri::HTML(resp['widget']).css('.stamped-review').each do |review|
          info = {
            rating: review.css('.stamped-starratings/.stamped-fa-star')&.length,
            title: review.at('.stamped-review-header-title')&.text&.strip,
            body: review.at('.stamped-review-content-body')&.text&.strip,
            reviewer_name: review.at('.author')&.text&.strip,
            review_date: parse_datetime(review.at('.stamped-review-content/.created')&.text&.strip, pattern: '%m/%d/%Y')
          }
          result << info.compact_blank
        end

        break if result.count >= resp['count'].to_i
        page += 1
      end
    rescue => e

    ensure
      return result.present? ? recursive_compact_blank(result) : nil
    end

    def calc_rating(reviews)
      return unless reviews.is_a?(Array)

      (reviews.inject(0.0) { |sum, el| sum + el[:rating] } / reviews.size.to_f).round(2)
    end
  end
end

class CigarsInternational < Parser
  BRANDS_URL = 'https://www.cigarsinternational.com/shop/big-list-of-cigars-brands/1803000/'

  class << self
    def store
      'Cigars International'
    end

    def host
      'www.cigarsinternational.com'
    end

    def user_agent
      'Mozilla/5.0 (X11; Linux i686; rv:115.0) Gecko/20170409 Firefox/115.0'
    end

    # def proxy
    #   Proxies::Brightdata.proxy_options
    # end

    def preload_images?
      true
    end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:'User-Agent'] ||= user_agent
      @h[:Host] ||= host if host.present?
      @h[:Referer] ||= root if root.present?
      @h[:Accept] ||= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      @h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @h[:Connection] ||= 'keep-alive'
      @h[:'Upgrade-Insecure-Requests'] = 1
      @h[:TE] = 'Trailers'
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def image_headers(options = {}, &block)
      if @ih.present?
        return @ih.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @ih = options || {}
      @ih[:'User-Agent'] ||= user_agent
      @ih[:Accept] ||= 'image/webp,*/*'
      @ih[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @ih[:Host] ||= 'img.cigarsinternational.com'
      @ih[:Referer] ||= "#{ root }/" if root.present?
      @ih[:Connection] ||= 'keep-alive'
      self.instance_exec @ih, &block if block.is_a?(Proc)
      @ih
    end

    def categories_urls
      [
        {
          name: 'Machine Made Cigars',
          link: 'https://www.cigarsinternational.com/shop/machine-made/1800039/?v=150',
        },
        *%w(
          https://www.cigarsinternational.com/shop/cigar-lighters/1800043/?v=150
          https://www.cigarsinternational.com/shop/cigar-cutters/1800044/?v=150
          https://www.cigarsinternational.com/shop/cigar-ashtrays/1800013/?v=150
        ).map { |link| { name: 'Accessories', link: link } }
      ]
    end

    def brands
      html = get_html BRANDS_URL

      if html.blank?
        log_error self.name, __method__, BRANDS_URL
        return
      end

      products = html.css('li[data-type="line"]/a.biglist-browser-mobile-view').map do |i|
        absolute_path i[:href]
      end

      brands = html.css('li[data-type="brand"]/a.biglist-browser-mobile-view').map do |i|
        { name: i.text&.strip, link: absolute_path(i[:href]) }
      end

      recursive_compact_blank({ products: products, brands: brands })
    end

    def pagination(&block)
      categories_urls.each do |category|
        cat = find_category category[:name]
        list_page_url = category[:link]

        loop do
          html = get_html list_page_url

          break if html.blank?

          products_urls = html
                              .css('.product-brand-heading/a')
                              .map { |i| absolute_path i[:href] }
                              .compact_blank

          next_page_node = html
                               .css('li.page-item/a.page-link')
                               .find { |i| i&.text&.strip&.downcase&.include?('next') }

          list_page_url = absolute_path nokogiri_try(next_page_node, :href)

          self.instance_exec products_urls, cat, &block if block.is_a?(Proc) && products_urls.present?

          break if list_page_url.blank?
        end
      end

      cat = find_category 'Cigars'
      products_urls = brands&.dig(:products)
      self.instance_exec products_urls, cat, &block if block.is_a?(Proc) && products_urls.present?
    end

    def product(url)
      html = get_html url
      return if html.blank? || html.at('#cf-error-details').present?

      info = { link: url }

      info[:title] = html.at('.prod-hgroup/h1/span')&.text&.strip

      if html.at('.descrption-div/.p').present?
        info[:description] = html.at('.descrption-div/.p').css('p').map {|p| p&.text&.strip }.reduce(:+)
      end

      if html.at('.stars-wrapper/span').present? && html.at('.stars-wrapper/span')['title'].present?
        info[:rating] = html.at('.stars-wrapper/span')['title']&.split(/\s+/)&.second
      end

      shapes = ''
      filters = %i(wrapper)

      html.css('.characteristics/tbody/tr').each do |i|
        case i.css('td').first&.text
        when 'Brand:', 'Brand'
          info[:brand_name] = nokogiri_try(i.css('td'), 1)&.text&.strip
        when 'Shapes'
          value =  nokogiri_try(i.css('td'), 1)&.text&.strip
          shapes = value if value.present?
        when 'Origin'
          value =  nokogiri_try(i.css('td'), 1)&.text&.strip&.gsub(',', ';')

          if value.present?
            info[:origin] = value
            info[:country_fltr] = value
          end
        else
          key =  i.css('td').first&.text&.strip&.gsub(/\s+/, '_')&.gsub(':', '')&.underscore&.to_sym
          value = nokogiri_try(i.css('td'), 1)&.text&.strip&.gsub(',', ';')

          if key.present? && value.present?
            info[key] = value
            info["#{ key }_fltr".to_sym] = value if filters.include?(key)
          end
        end
      end

      info[:images] = html.css('#products-carousel/.item/a').map do |i|
        i[:href]&.gsub('//', 'https://')
      end.compact_blank

      info[:reviews] = html.css('.review-ratings').map do |review|
        {
          rating: review.at('.stars/span')&.text&.strip&.split(/\s+/)&.first,
          title: review.at('.feedback-text')&.text&.strip,
          body: review.at('.review-text')&.text&.strip,
          reviewer_name: review.at('.by-name')&.text&.strip,
          review_date: parse_datetime(review.at('.publishDate')&.text&.strip)
        }.compact_blank
      end.compact_blank

      prev_title = nil

      info[:products] = html.css('div[id*="prod-item-"]').map do |i|
        item = {}

        %i(type stock).each do |key|
          item[key] = i.at("div.prod-#{ key }")&.text&.strip
        end

        # TODO status (stock Backordered)

        item[:price] = price_to_i nokogiri_try(i.at('.prod-price/.price-product/span'), 'data-value')
        item[:old_price] = price_to_i nokogiri_try(i.at('.prod-msrp/span/.text-decoration-linethrough/span'), 'data-value')
        item[:discount] = price_to_i i.at('.prod-msrp/div/span/.price-amount')&.text&.strip

        item[:link] = absolute_path nokogiri_try(i.at('div/a'), 'data-url')
        title = i.at('div.product-brand-heading')&.text&.strip
        shape_el = i.at('div.product-brand-heading/.cigar-shape')

        prev_title = title if title.present?
        title = prev_title if title.blank?

        if shape_el.present?
          shape = shape_el&.text&.strip&.gsub(/[()]+/, '')
        elsif shapes.present?
          shape = (title.split(/\s+/) & shapes.split(',').map { |i| i.gsub(/\A\p{Space}*/, '') }).first
        end

        prev_shape = shape if shape.present?
        shape = prev_shape if shape.blank?

        item[:title] = title
        item[:shape_fltr] = shape
        item[:shape] = shape

        item.compact_blank
      end.compact_blank

      recursive_compact_blank info
    end

    def build_attributes(details, except: [])
      _attributes = super(details.except :images)
      _attributes[:specifications]&.delete :products

      if details[:images].present? && (except.blank? || except.exclude?(:images))
        _attributes[:attachments_attributes] = details[:images].map do |img|
          { attachment: get_image(img) }
        end
      end

      _attributes
    end

    def store_product!(info, category: nil, &block)
      return if info.blank?

      _attributes = build_attributes info
      _variant_keys = %i(price old_price discount link shape_fltr status)
      _variant_specifications_keys = %i(type stock shape)

      info[:products]&.each do |variant|
        _product_attributes = _attributes.merge(variant.slice(*_variant_keys))
        _product_attributes[:title] = [_product_attributes[:title], variant[:title]].compact_blank.join(' | ')
        _product_attributes[:specifications] = (_product_attributes[:specifications] || {})
                                                   .merge(variant.slice(*_variant_specifications_keys))

        if block.is_a?(Proc)
          self.instance_exec _product_attributes, &block
        else
          _product = Product.find_by link: _product_attributes[:link]

          if _product.present?
            _product.status = _product_attributes[:status] if _product_attributes[:status].present?
          else
            _product = Product.new _product_attributes
          end

          _product.category = category if category.present?
          _product.resource = resource

          log_error _product.errors.messages unless _product.save
        end
      end
    rescue => e
      log_error self.name, __method__, e.message
    end
  end
end

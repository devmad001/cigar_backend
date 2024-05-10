class BnbTobacco < Parser
  class << self
    def store
      'BnB Tobacco'
    end

    def host
      'www.bnbtobacco.com'
    end

    def user_agent
      'Mozilla/5.0 (X11; U; Linux x86_64) Gecko/20062211 Firefox/115.0'
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
      @h[:'Upgrade-Insecure-Requests'] ||= 1
      @h[:TE] ||= 'Trailers'
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          link: 'https://www.bnbtobacco.com/pages/premium-cigar-brands'
        },
        {
          name: 'Cigars',
          link: 'https://www.bnbtobacco.com/pages/little-cigar-brands'
        },
        {
          name: 'Machine Made Cigars',
          link: 'https://www.bnbtobacco.com/pages/machine-made-brands'
        },
        {
          name: 'Tobacco',
          link: 'https://www.bnbtobacco.com/pages/pipe-tobacco-brands'
        }
      ]
    end

    def pagination(&block)
      categories_urls.each do |category|
        cat = find_category category[:name]

        parse_brands(category[:link])&.each do |brand|
          products_urls = parse_products brand[:link]
          self.instance_exec products_urls, cat, brand[:name], &block if block.is_a?(Proc) && products_urls.present?
        end
      end
    end

    def each_products(type: :all, &block)
      pagination do |links, category, brand_name|
        filter_products_links(links, type: type, category: category).each do |link|
          self.instance_exec product(link, brand_name: brand_name), category, &block if block.is_a?(Proc)
        end
      end
    end

    def store_product!(info, category: nil, &block)
      return if info.blank?
      _attributes = build_attributes info
      _variant_keys = %i(price old_price discount link status title)

      info[:products]&.each do |variant|
        _product_attributes = _attributes.merge variant.slice(*_variant_keys)
        _product_attributes[:specifications] = (_product_attributes[:specifications] || {}).merge(variant.slice(:type))

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

    def build_attributes(details)
      _attributes = super
      _attributes[:specifications]&.delete :products
      _attributes
    end

    def product(url, brand_name = nil)
      html = get_html url
      return if html.blank?

      info = { link: url, brand_name: brand_name }.compact_blank
      info[:title] = html.at('.ab-single-product/.section-header/h1')&.text&.strip
      info[:description] = html.at('.product-description')&.css('p')&.map { |p| p&.text&.strip }&.join("\n")
      price = html.at('#tabs-1').css('form')&.first

      if price.present?
        info[:name] = price.at('.tab-options.product/h2')&.text&.strip
        info[:packaging] = price.at('.tab-options.packaging/span')&.text&.strip
        info[:price] = price_to_i price.at('.tabin-price/span')&.text&.split('Save')&.first&.strip
        info[:old_price] = price_to_i price.at('.tabin-msp/span')&.text&.strip

        if info[:old_price] && info[:price] && info[:old_price] < info[:price]
          info[:discount] = info[:old_price] - info[:price]
        end
      end

      #specifications
      filters = %i(length wrapper strength shape)

      html.at('.product-information-dtl.desktop').css('.product-information-row').each do |i|
        value = i.at('.product-information-items').css('.product-information-item')&.first&.text&.strip&.gsub(',', '')

        case i.at('.product-information-title')&.text
        when 'Brand'
          info[:brand_name] ||= value
        when 'Country of origin'
          info[:country_fltr] = value
          info[:country] = value
        when 'Ring gauge'
          info[:ring] = value
        else
          key = i.at('.product-information-title')&.text&.strip&.gsub(/\s+/, '_')&.underscore&.to_sym

          if key.present? && value.present?
            info[key] = value
            info["#{ key }_fltr".to_sym] = value if filters.include?(key)
          end
        end
      end

      #images
      image = nokogiri_try(html.at('#ProductPhoto/img'), 'data-src')&.gsub('//', 'https://')
      info[:images] = [image] if image.present?

      #options
      info[:products] = html.css('#tabs-1/form').map do |i|
        optionId =  nokogiri_try i.at('input[name="id"]'), 'value'

        item = { link: "#{ url }##{ optionId }" }

        data = i.at('.tab-options.product')
        item[:title] = info[:title]

        if data.present?
          item[:title] = [info[:title], data.at('h2')&.text&.strip].compact_blank.join(' | ')
          item[:type] = data.at('span')&.text&.strip
        end

        if i.at('.tabin-price').present?
          item[:price] = price_to_i i.at('.tabin-price/span')&.text
          item[:old_price] = price_to_i i.at('.tabin-msp/span')&.text

          if item[:old_price] && item[:price] && item[:old_price] < item[:price]
            item[:discount] = item[:old_price] - item[:price]
          end
        end

        if nokogiri_try(i.at('.tabin-stock-availability/img'), 'data-src')&.include?('check-right')
          item[:status] = :active
        else
          item[:status] = :inactive
        end

        item.compact_blank
      end.compact_blank

      if (pid = Yotpo.resource_pid html).present?
        app_key = 'Z27A76DgfCrjO46QR080KW7KFQubD2Wh2Wso5hUL'
        widget_version = '2023-07-05_08-43-33'

        reviews_attributes = Yotpo.reviews pid: pid,
                                           app_key: app_key,
                                           origin: root,
                                           widget_version: widget_version,
                                           rating: false

        info.merge! reviews_attributes if reviews_attributes.present?

        info[:rating] = Yotpo.rating pid: pid,
                                     app_key: app_key,
                                     origin: root,
                                     widget_version: widget_version
      end

      recursive_compact_blank info
    end

    private

    def parse_brands(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      html.css('li.collection-item/h4/a').map do |i|
        { name: i.text&.strip, link: absolute_path(i[:href]) }.compact_blank
      end.compact_blank
    end

    def parse_products(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      html.css('div.product-grid-item/div.block/h4/a').map do |i|
        absolute_path i[:href]
      end.compact_blank
    end
  end
end

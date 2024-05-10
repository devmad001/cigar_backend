class Jrcigars < Parser
  class << self
    PER_PAGE = 60

    def store
      'JR Cigar'
    end

    def host
      'www.jrcigars.com'
    end

    def user_agent
      'Mozilla/5.0 (X11; Linux x86_64; en-US; rv:119.0) Gecko/20160404 Firefox/119.0'
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
      @h[:'Connection'] ||= 'keep-alive'
      @h[:'Upgrade-Insecure-Requests'] = 1
      @h[:'Cache-Control'] ||= 'max-age=0'
      @h[:TE] ||= 'Trailers'
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          link: 'https://www.jrcigars.com/cigars/handmade-cigars/'
        },
        {
          name: 'Machine Made Cigars',
          link: 'https://www.jrcigars.com/cigars/machine-made-cigars/'
        },
        {
          name: 'Tobacco',
          link: 'https://www.jrcigars.com/pipe-tobacco/'
        },
        {
          name: 'Accessories',
          link: 'https://www.jrcigars.com/cigar-accessories/'
        }
      ]
    end

    def pagination(&block)
      categories_urls.map do |category|
        cat = find_category category[:name]

        brands = parse_brands(category[:link])
        return if brands.blank?

        brands.each do |brand|
          parse_products brand, category: cat, &block
        end
      end
    end

    def each_products(type: :all, &block)
      pagination do |products, cat|
        filtered_links = filter_products_links(products.map { |p| p[:link] }, type: type, category: cat)
        products.select { |p| filtered_links.include?(p[:link]) }.each do |pr|
          self.instance_exec product(pr[:link], pr[:brand_name], pr[:product_type]), cat, &block if block.is_a?(Proc)
        end
      end
    end

    def product(url, brand_name = nil, product_type = nil)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      info = {
        link: url,
        brand_name: brand_name,
        product_type: product_type
      }

      info[:description] = html.at('div.item-description')&.text&.strip
      info[:title] = html.at('div.col-sm-9.page-item/h1.tight')&.text&.strip
      info[:name] = html.at('div.col-sm-9.page-item/h3[itemprop="name"]')&.text&.strip
      info[:price] = html.at('.jr-price/span')&.text&.gsub('$', '')&.gsub('.', '')&.to_i
      info[:old_price] = html.at('.msrp-price/span')&.text&.gsub('$', '')&.gsub('.', '')&.to_i

      if html.at('button.addtocart-button').present?
        info[:status] = :active
      else
        info[:status] = :inactive
      end

      filters = %i(shape strength)

      html.css('div.cigar-details/div/div/div.col-sm-4').each do |item|
        key = item.at('label.control-label')&.text&.strip&.gsub(/\s+/, '_')&.underscore&.to_sym
        value = item.at('div.col-xs-7/p.form-control-static')&.text&.strip

        if key.present? && value.present?
          info[key] = value
          info["#{ key }_fltr".to_sym] = value if filters.include?(key)
          info[:country_fltr] = value if key == :origin
          info[:wrapper_fltr] = value if key == :wrapper_type
        end
      end

      if (yotpo_widget = Yotpo.widget_block html).present? &&
          (pid = yotpo_widget['data-product-id']).present? &&
          (app_key = yotpo_widget['data-appkey']).present?
        reviews_attributes = Yotpo.reviews pid: pid,
                                           app_key: app_key,
                                           origin: root,
                                           widget_version: '2023-07-05_08-43-33',
                                           rating: false

        info.merge! reviews_attributes if reviews_attributes.present?

        info[:rating] = Yotpo.rating pid: pid,
                                     app_key: app_key,
                                     origin: root,
                                     widget_version: '2023-07-05_08-43-33'
      end

      info[:images] = html.css('button.img-thumb/img')&.map do |img|
        URI.encode img['data-imghires']&.strip.to_s
      end.compact_blank

      recursive_compact_blank info
    end

    def build_attributes(details)
      _attributes = super
      _attributes[:title] = [_attributes[:title], _attributes[:name]].compact_blank.join(' | ')
      _attributes.compact_blank
    end

    private

    def parse_brands(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      html.css('.brands-list-content/p/.link-bare.bold').map do |l|
        { name: l&.text&.strip, link: l['href'] }.compact_blank
      end.compact_blank
    end

    def parse_products(brand, category: nil, &block)
      products = []
      page = 0

      while true
        puts "page: #{ brand } #{ page + 1 }".yellow

        ps = product_parser brand, page
        break if ps.blank?
        products += ps
        page += 1

        self.instance_exec ps, category, &block if block.is_a?(Proc)
      end

      products.compact_blank
    end

    def product_parser(brand, page)
      html = get_html brand[:link] + "?sz=#{ PER_PAGE }&start=#{ PER_PAGE * page.to_i }"

      if html.blank?
        log_error self.name, __method__, brand[:link]
        return
      end

      type = html.at('#bc_2/a/span')&.text&.strip

      html.css('.item-link/.product-tile-link').map do |l|
        {
          link: 'https://www.jrcigars.com' + l['href'],
          brand_name: brand[:name].gsub("'", ''),
          product_type: type
        }.compact_blank
      end.compact_blank
    end
  end
end

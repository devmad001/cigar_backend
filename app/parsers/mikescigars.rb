class Mikescigars < Parser
  PER_PAGE = 24
  BREADCRUMBS = ['brands', 'samplers', 'dbl stacks'].freeze

  class << self
    def host
      'mikescigars.com'
    end

    def store
      'Mike\'s Cigars'
    end

    def preload_images?
      true
    end

    def user_agent
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:118.0esr) Gecko/20000101 Firefox/118.0esr/97AQJlHi5JlM-25'
    end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:'Accept'] ||= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      @h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @h[:'Connection'] ||= 'keep-alive'
      @h[:'DNT'] ||= %w(0 1).sample
      @h[:'Host'] ||= self.host if self.host.present?
      @h[:'Referer'] ||= self.root if self.root.present?
      @h[:'Upgrade-Insecure-Requests'] ||= '1'
      @h[:'User-Agent'] ||= user_agent
      @h[:'Sec-Fetch-Dest'] ||= 'document'
      @h[:'Sec-Fetch-Mode'] ||= 'navigate'
      @h[:'Sec-Fetch-Site'] ||= 'same-origin'
      @h[:'Sec-Fetch-User'] ||= '?1'
      @h[:'TE'] ||= 'trailers'
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def ajax_headers(options = {}, &block)
      if @ajax_h.present?
        return @ajax_h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @ajax_h = options || {}
      @ajax_h[:'Accept'] ||= 'application/json, text/javascript, */*; q=0.01'
      @ajax_h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @ajax_h[:'Connection'] ||= 'keep-alive'
      @ajax_h[:'DNT'] ||= %w(0 1).sample
      @ajax_h[:'Host'] ||= self.host if self.host.present?
      @ajax_h[:'Referer'] ||= 'https://mikescigars.com/cigars/brands' if self.root.present?
      @ajax_h[:'Sec-GPC'] ||= '1'
      @ajax_h[:'User-Agent'] ||= user_agent
      @ajax_h[:'X-Requested-With'] ||= 'XMLHttpRequest'
      @ajax_h[:'TE'] ||= 'trailers'
      self.instance_exec @ajax_h, &block if block.is_a?(Proc)
      @ajax_h
    end

    def image_headers(options = {}, &block)
      super
      @ih.delete :'Referer'
      @ih[:'Sec-GPC'] = 1
      @ih[:'Upgrade-Insecure-Requests'] = 1
      @ih[:'TE'] = 'Trailers'
      @ih
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          links: %w(
            https://mikescigars.com/cigar-samplers
            https://mikescigars.com/double-stacks
          ),
          brands: %w(https://mikescigars.com/categorylist/ajax/subcategories/?page_number=1&brand=all&current_category_id=38)
        },
        {
          name: 'Accessories',
          links: %w(
            https://mikescigars.com/humidors
            https://mikescigars.com/cutters
            https://mikescigars.com/ashtrays
            https://mikescigars.com/accessories
          )
        }
      ]
    end

    def pagination(&block)
      categories_urls.map do |category|
        cat = find_category category[:name]

        category[:links]&.each do |link|
          each_pages link, cat, &block
        end

        category[:brands]&.each do |link|
          each_brands link do |pages_links|
            pages_links.each do |page_link|
              each_pages page_link, cat, assign_per_page: false, &block
            end
          end
        end
      end
    end

    def product(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      content = html.at('#maincontent')

      if content.blank?
        log_error self.name, __method__, url
        return
      end

      info = { link: url }
      info[:title] = content.at('h1.page-title')&.text&.strip
      info[:description] = content.at('div#description')&.text&.strip
      info[:price] = price_to_i content.at('span.price')&.text
      info[:old_price] = price_to_i content.at('span.price_msrp')&.text&.gsub(/MSRP|:|\s+/, '')

      content
          .css('div.attributes_full/div.product-atribute')
          &.map { |attribute| attribute.text&.strip }
          &.compact
          &.uniq
          &.map do |attribute|
            key, value = attribute.split(':')&.map(&:strip)

            value = value&.split(/\s*,\s*/)&.map do |i|
              if %w(USA).include?(i)
                i
              else
                i.downcase.split(/\s+/).map(&:capitalize).join(' ')
              end
            end&.join(', ')

            info[key.downcase.underscore.gsub(/\s+/, '_').to_sym] = value if key.present? && value.present?
          end

      info[:sku] ||= content.at('div.product-sku-attribute')&.text&.split(':')&.last&.strip
      brand_index = html
                        .css('.breadcrumbs/.items/.item/a')
                        .index { |i| BREADCRUMBS.include?(i.text&.strip&.downcase) }

      if brand_index.present?
        info[:brand_name] = html.css(".breadcrumbs/.items/[class=\"item #{ brand_index.next }\"]/a")&.text&.strip
      end

      if html.at('button#product-addtocart-button').present?
        info[:status] = :active
      else
        info[:status] = :inactive
      end

      info[:images] = images html
      info.merge!(reviews(html) || {})

      recursive_compact_blank info
    end

    def build_attributes(details, except: [])
      _attributes = super(details.except :images)

      if details[:images].present? && (except.blank? || !except.include?(:images))
        _attributes[:attachments_attributes] = details[:images].map do |img|
          { attachment: get_image(img, use_proxy: false) }
        end
      end

      recursive_compact_blank _attributes
    end

    private

    def each_pages(url, category, assign_per_page: true, &block)
      category_url = url
      category_url += "?product_list_limit=#{ PER_PAGE }" if assign_per_page
      page = 1

      loop do
        page_url = category_url
        page_url += assign_per_page ? '&' : '?'
        page_url += "p=#{ page }" if page > 1
        html = get_html page_url

        if html.blank?
          log_error self.name, __method__, page_url
          return
        end

        page += 1
        products_urls = html
                            .css('.product-item-info/a.product.photo.product-item-photo')
                            .map { |a| a['href'] }
                            .compact_blank

        self.instance_exec products_urls, category, &block if block.is_a?(Proc)
        break if products_urls.blank? || html.css('.item.pages-item-next').blank?
      end
    end

    def each_brands(url, category = nil, &block)
      resp = { nex_page: url }

      loop do
        resp = ajax_items resp[:nex_page]
        break if resp[:pages].blank? || resp[:nex_page].blank?
        self.instance_exec resp[:pages], category, &block if block.is_a?(Proc)
      end
    end

    # def ajax_link(url, next_page: false)
    #   base, query = url.split '?'
    #   params = {}
    #
    #   query.split('&').each do |i|
    #     k, v = i.split '='
    #     params[k] = v if k.present? && v.present?
    #   end
    #
    #   params['page_number'] = params['page_number'].to_i.next if params['page_number'].present? && next_page
    #   params['_'] = DateTime.now.to_i * 1000 + rand(3)
    #   params.compact_blank
    #   new_url = base
    #   new_url += "?#{ params.to_query }" if params.present?
    #   new_url
    # end

    def ajax_items(url)
      # resp = get_resp ajax_link(url), headers: ajax_headers
      resp = get_resp url, headers: ajax_headers

      if (body = resp.body) && body.index('"') && body.rindex('"')
        body = body[1...-1]
                   &.strip
                   &.gsub(/\s+/, ' ')
                   &.gsub('\n', ' ')
                   &.gsub("\\", '')
                   &.gsub(" ", ' ')
                   &.gsub(/\s+/, ' ')

        body = "<html><head></head><body><div>#{ body }</div></body></html>"
      end

      if body.blank?
        log_error self.name, __method__, url
        return
      end

      html = Nokogiri::HTML body

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      info = {}
      info[:pages] = html.css('.desktop-category/a.thumbnail').map { |a| a['href'] }.compact
      # info[:nex_page] = ajax_link url, next_page: true
      info[:nex_page] = nokogiri_try html.at('.item.pages-item-next/a.action.next'), 'href'
      recursive_compact_blank info
    rescue => e

    end

    def images(html)
      _json = html
                 &.css('script[type*="x-magento-init"]')
                 &.find { |script| script.text =~ /data-gallery-role=gallery-placeholder/ }
                 &.text

      return if _json.blank?

      _images = JSON
                    .parse(_json)
                    &.dig('[data-gallery-role=gallery-placeholder]', 'Botta_Catalog/js/gallery', 'data')
                    &.map { |img| img['full'] || img['img'] || img['thumb'] }

      _regexp = /(cache\/\h+\/)/

      if _images.count > 0 && _images.last =~ _regexp
        _replace = $1
        _images += html
                       .css('img.img-product')
                       &.map { |img| img['data-po-cmp-src']&.gsub(_regexp, _replace) } || []
      end

      _images.compact.uniq
    rescue => e

    end

    def reviews(html)
      script = html
                   &.css('script[type="application/ld+json"]')
                   &.find { |script| script.text&.include?('"@type":"Review"') }
                   &.text
                   &.strip

      return if script.blank?

      data = JSON.parse(script)

      _reviews = data['review'].map do |review|
        {
          title: review['name'],
          body: review['reviewBody'],
          rating: review['rating'],
          review_date: DateTime.parse(review['datePublished']),
          reviewer_name: review.dig(*%w(author name))
        }
      end.compact

      { reviews: _reviews, rating: data.dig('aggregateRating', 'ratingValue') }.compact_blank
    rescue => e

    end
  end
end

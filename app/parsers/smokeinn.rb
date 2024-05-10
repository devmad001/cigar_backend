class Smokeinn < Parser
  BRANDS_URL = 'https://www.smokeinn.com/Cigar-List'
  DEFAULT_IMAGE = 'default_image.gif'

  class << self
    def store
      'Smoke Inn'
    end

    def host
      'www.smokeinn.com'
    end

    def user_agent
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:114.0) Gecko/20100101 Firefox/114.0'
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
      @h[:'Cache-Control'] ||= 'max-age=0'
      @h[:Connection] ||= 'keep-alive'
      @h[:'If-Modified-Since'] ||= DateTime.now.httpdate
      @h[:'Upgrade-Insecure-Requests'] = 1
      @h[:TE] ||= 'Trailers'
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          link: 'https://www.smokeinn.com/samplers/'
        },
        {
          name: 'Cigars',
          link: 'https://www.smokeinn.com/Value-Bundles/'
        },
        {
          name: 'Accessories',
          link: 'https://www.smokeinn.com/cigar-accessories/'
        }
      ]
    end

    def brands
      html = get_html BRANDS_URL

      if html.blank?
        log_error self.name, __method__, BRANDS_URL
        return
      end

      html.css('ul.cigar_list_group/li/a').map do |i|
        { name: compact_spaces(i.text), link: i[:href] }.compact_blank
      end.compact_blank
    end

    def product(url, brand_name: nil)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      brand_name ||= html.at('div#location')&.text&.strip&.split(/\s*::\s*/)&.dig(-2)
      image = nokogiri_try html.at('div.image_product/div.image/div.image-box/img'), :src

      info = {
        link: url,
        brand_name: brand_name,
      }

      info[:images] = [image] if image.present? && image.exclude?(DEFAULT_IMAGE)

      details = html.at 'div.details_product'

      if details.present?
        info[:title] = compact_spaces details.at('h1')&.text

        description_block = details.at('div.descr')

        if description_block.present?
          description_block.css('script')&.remove
          description_block.css('style')&.remove

          description_block.css('p').each do |i|
            content = i.text

            if content =~ /\s*•\s*(.+?)\s*:\s*(.+?)/
              info.merge! parse_properties(content.split(/\s*•\s*/)).compact_blank
              i.remove
            end
          end

          info[:description] = compact_spaces description_block&.text
        end

        if details.at('div.creviews-rating-box/div')['title'] =~ /rating:\s+(\d+\.?\d*);/
          info[:rating] = ($1.to_f * 0.05).round 2
        end

        %w(h1 div.cls_product_rating div.descr div.ask-question).each do |selector|
          details.at(selector)&.remove
        end

        info.merge! parse_properties(details.text&.strip&.split("\n")).compact_blank

        properties = html.at('div.product-properties')

        if properties.present?
          info[:sku] = properties.at('div#product_code.property-value')&.text&.strip
          info[:old_price] = price_to_i properties.at('div.property-value.product-taxed-price')&.text
          info[:price] = price_to_i properties.at('span.product-price-value')&.text

          if properties
                 .at('div.quantity-row.quantity_row_cls/div.product-input/div.quantity')
                 &.text&.downcase&.include?('out of stock')
            info[:status] = :inactive
          else
            info[:status] = :active
          end
        end

        info[:reviews] = html.css('ul.creviews-reviews-list/li/div.row').map do |i|
          stars = i.css('p.color')
          header = i.at('strong')
          parts = header&.text&.strip&.split(/\s+-\s+/)

          stars.remove
          header.remove
          i.css('strong').remove
          i.css('script').remove

          {
            rating: stars.count,
            reviewer_name: parts&.first,
            title: parts&.slice(1..-1)&.join(' - '),
            body: compact_spaces(i.text)
          }
        end

        recursive_compact_blank info
      end
    end

    def pagination(&block)
      categories_urls.each do |category|
        cat = find_category category[:name]
        paginate_list category[:link], cat, &block
      end

      cat = find_category 'Cigars'

      brands&.each do |brand|
        paginate_list brand[:link], cat, brand[:name], &block
      end
    end

    def each_products(type: :all, &block)
      pagination do |links, cat, brand_name|
        filter_products_links(links, type: type, category: cat).each do |link|
          self.instance_exec product(link, brand_name: brand_name), cat, &block if block.is_a?(Proc)
        end
      end
    end

    private

    def parse_properties(rows)
      info = {}

      rows&.each do |row|
        if row.strip =~ /^(.+?)\s*:\s*(.+?)$/
          key, value = $1, $2
          info[key.downcase.gsub(/\s+/, '_').underscore.to_sym] = value
        end
      end

      info
    end

    def list_page(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      next_page = html.at('.nav-pages/a.right-arrow').present?

      products_urls = html.css('a.product-title.title_grid_view').map do |i|
        nokogiri_try i, :href
      end.compact_blank

      products_urls += html.css('div.product_name.product_grid.product_custom_class/a.product-title').map do |i|
        nokogiri_try i, :href
      end.compact_blank

      { next_page: next_page, urls: products_urls }
    end

    def paginate_list(url, category, brand_name = nil, &block)
      page = 1

      loop do
        list_page_url = url
        list_page_url += "?page=#{ page }" if page > 1
        list_data = list_page list_page_url
        products_urls = list_data[:urls]
        page += 1
        self.instance_exec products_urls, category, brand_name, &block if block.is_a?(Proc) && products_urls.present?
        break unless list_data[:next_page]
      end
    end
  end
end

class Dd8shop < Parser
  class << self
    # CANONICAL_FIELDS = %i(title name description link price old_price)

    def host
      'www.dd8shop.com'
    end

    def store
      'DirectDelta8'
    end

    def headers(options = {}, &block)
      us = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.131 Safari/537.36'

      h = options || {}
      h['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      h['Accept-Language'] = 'en-US,en;q=0.5'
      h['Connection'] = 'keep-alive'
      h['DNT'] ||= %w(0 1).sample
      h['Host'] ||= host if host.present?
      h['Referer'] ||= root
      h['Upgrade-Insecure-Requests'] = '1'
      h['User-Agent'] ||= us
      self.instance_exec h, &block if block.is_a?(Proc)
      h
    end

    def categories
      {
        'E-liquid' => %w(
                          https://www.dd8shop.com/product-category/delta-10/
                          https://www.dd8shop.com/product-category/distillate/
                        ),
        'Devices' => %w(
                          https://www.dd8shop.com/product-category/delta-8-vape/
                          https://www.dd8shop.com/product-category/thc-p/
                          https://www.dd8shop.com/product-category/thc-o/
                        )
      }
    end

    def list(url)
      html = get_html url
      return if html.blank?
      info = {}
      info[:products] = html.css('ul.products/li').map do |i|
        item = {}
        item[:link] = nokogiri_try i.at('a'), :href
        item[:image] = nokogiri_try i.at('a/img'), :src
        item[:title] = i.at('a/h2')&.text&.strip

        price_raw = i.at('a/span.price')

        if price_raw.present?
          if (old_price = price_raw.at('del')).present?
            item[:old_price] = price_to_i old_price&.text&.strip&.split(/\s*-\s*/)&.first
            old_price.remove
          end
          item[:price] = price_to_i price_raw&.text&.strip&.split(/\s*-\s*/)&.first
        end

        item
      end
      info[:pages] = pages html
      info
    end

    def items(url)
      html = get_html url
      return if html.blank?
      info = {}
      info[:products] = html.css('ul.products/li').map do |i|
        nokogiri_try i.at('a'), :href
      end.compact
      info[:pages] = pages html
      info
    end

    def product(url)
      html = get_html url
      info_block = html&.at('#main-content')
      return if html.blank? || info_block.blank?
      info = {
        link: url
      }
      if (summary = info_block.at('div.summary')).present?
        info[:title] = summary.at('h1.product_title')&.text&.strip

        price_raw = summary.at('p.price')

        if price_raw.present?
          if (old_price = price_raw.at('del')).present?
            info[:old_price] = price_to_i old_price&.text&.strip&.split(/\s*-\s*/)&.first
            old_price.remove
          end
          info[:price] = price_to_i price_raw&.text&.strip&.split(/\s*-\s*/)&.first
        end

        info[:name] = summary.at('div.woocommerce-product-details__short-description')&.text&.strip

        summary.css('div.product_meta/span').map do |i|
          if i.text&.strip =~ /^([^:]+?)\s*:\s*(.+)$/
            info[$1.underscore.to_sym] = $2
          end
        end
      end

      info[:description] = info_block.at('div#tab-description')&.text&.strip
      info[:images] =  info_block
                           .css(
                             'figure.woocommerce-product-gallery__wrapper/'\
                              'div.woocommerce-product-gallery__image/a'
                           )
                           .map { |i| nokogiri_try i, :href }
      info.compact
    end

    def each_category_pages(url = nil, category: nil, &block)
      next_page = true
      page = 1
      base_url = "#{ url.present? ? url : "#{ root }/shop/" }?fwp_paged="
      while next_page do
        puts "page: #{ page }".yellow
        next_page = false
        _items = items "#{ base_url }#{ page }"
        if _items.present? && _items[:products].present?
          self.instance_exec _items[:products], category, &block if block.is_a?(Proc)
          if _items[:pages].present? && _items[:pages][:current] < _items[:pages][:last]
            next_page = true
            page += 1
          end
        end
      end
    end

    def each_category_products(url = nil, category: nil, &block)
      each_category_pages url, category: category do |links, category|
        links&.each do |link|
          self.instance_exec product(link), category, &block if block.is_a?(Proc)
        end
      end
    end

    def pagination(&block)
      self.categories.each do |title, links|
        _category = find_category title

        links.each { |link| each_category_pages link, category: _category, &block }
      end
    end

    def each_products(type: :all, &block)
      self.categories.each do |title, links|
        _category = find_category title

        links.each { |link| each_category_products link, category: _category, &block }
      end
    end

    def pages(html)
      return unless html.css('script')
                        .select { |s| s[:src].blank? && s.text =~ /^\s*(window.FWP_JSON)/ }
                        .first.text =~ /.+?({.+)[^}]+?$/

      pages_block = Nokogiri::HTML JSON.parse($1).dig(*%w(preload_data facets pagination))
      return if pages_block.blank?

      {
        first: pages_block.at('a.first')&.text&.strip.to_i,
        last: pages_block.at('a.last')&.text&.strip.to_i,
        current: pages_block.at('a.active')&.text&.strip.to_i
      }
    rescue => e
      log_error e.message
    end

    def build_attributes(info)
      _attributes = super
      _attributes[:brand_name] = BrandsService.brand_name info[:brand] if info[:brand].present?
      _attributes[:specifications] = info.except(*(CANONICAL_FIELDS + %i(brand images)))
      _attributes
    end
  end
end

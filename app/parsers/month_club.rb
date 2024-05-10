class MonthClub < Parser
  class << self
    # CANONICAL_FIELDS = %i(title description link price brand_name)

    def host
      'www.cigarmonthclub.com'
    end

    def store
      'Cigars Month Club'
    end

    def user_agent
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_16; rv:114.0esr) Gecko/20110101 Firefox/114.0esr'
    end

    # def proxy
    #   Proxies::Brightdata.proxy_options
    # end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:Accept] ||= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      @h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @h[:'Cache-Control'] ||= 'max-age=0'
      @h[:Connection] ||= 'keep-alive'
      @h[:DNT] ||= %w(0 1).sample
      @h[:Host] ||= host if host.present?
      @h[:Origin] ||= root if root.present?
      @h[:Referer] ||= root if root.present?
      @h[:TE] ||= 'Trailers'
      @h[:'Upgrade-Insecure-Requests'] ||= 1
      @h[:'User-Agent'] ||= user_agent
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def categories_urls
      [
        {
          name: 'Cigars',
          links: %w(
            https://www.cigarmonthclub.com/reorder-your-favorites?product_list_limit=24
            https://www.cigarmonthclub.com/reorder-your-favorites?product_list_limit=24&p=2
          )
        }
      ]
    end

    def list(url)
      html = get_html url
      return if html.blank?
      html.css('.product-item-info/.product.photo.product-item-photo').map { |l| l['href'] }
    end

    def product(url)
      html = get_html url
      return if html.blank? || (item = html.at_css('main#maincontent')).blank?

      info = { link: url }

      info[:title] = item.at('h1.product.attribute')&.text&.strip
      info[:description] = item.css('div.tab/.block.milk/div/div/p').map { |p|  p.text&.strip }.join("\n")
      information = item.at('.product-custom-information-wrapper')
      info[:brand_name] = information.at('.product-custom-attributes/p/a')&.text&.strip
      info[:price] = nokogiri_try(html.at('meta[property="product:price:amount"]'), 'content')&.gsub('.','').to_i

      if html.at('button#product-addtocart-button').present?
        info[:status] = :active
      else
        info[:status] = :inactive
      end

      filters = %i(strength shape country)

      item.css('.product-custom-attributes/.row').each do |i|
        key = i.css('div').first&.at('p')&.text&.strip&.gsub(/\s+/, '_')&.gsub(':', '')&.underscore&.to_sym
        value = nokogiri_try(i.css('div'), 1)&.at('p')&.text&.strip

        if key.present? && value.present?
          info[key] = value
          info["#{ key }_fltr".to_sym] = value if filters.include?(key)
        end
      end

      begin
        data = JSON.parse(
            html
                .css('script[type="text/x-magento-init"]')
                .find { |script| script.content =~ /data-gallery-role=gallery-placeholder/ }
                .content
        )

        images = data
                     .dig(*%w([data-gallery-role=gallery-placeholder] Scandi_MagicZoom/js/gallery data))
                     &.map do |i|
          i.slice(*%w(full videoUrl)).values.compact_blank
        end&.flatten&.compact_blank
      rescue => e
        images = [nokogiri_try(html.at('meta[property="og:image"]'), 'content')].compact_blank
      end

      info[:images] = images if images.present?

      recursive_compact_blank info
    end

    def pagination(&block)
      categories_urls.each do |category|
        cat = find_category category[:name]

        category[:links].each do |link|
          products_urls = list link
          self.instance_exec products_urls, cat, &block if block.is_a?(Proc) && products_urls.present?
        end
      end
    end
  end
end

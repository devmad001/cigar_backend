class ThompsonCigar < Parser
  BRANDS_URL = 'https://www.thompsoncigar.com/shop/all-cigar-brands/8336/'

  class << self
    def store
      'Thompson Cigar'
    end

    def host
      'www.thompsoncigar.com'
    end

    # def proxy
    #   Proxies::Brightdata.proxy_options
    # end

    def user_agent
      'Mozilla/5.0 (Windows NT 10.0; WOW64; rv:113.0) Gecko/20010101 Firefox/113.0'
    end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:'User-Agent'] ||= user_agent
      @h[:Host] ||= host if host.present?
      @h[:Origin] ||= root if root.present?
      @h[:Referer] ||= root if root.present?
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
          name: 'Machine Made Cigars',
          link: 'https://www.thompsoncigar.com/shop/all-machine-made-cigars/9102/',
        },
        {
          name: 'Accessories',
          link: 'https://www.thompsoncigar.com/shop/accessories/8406/',
        }
      ]
    end

    def brands
      html = get_html BRANDS_URL

      if html.blank?
        log_error self.name, __method__, BRANDS_URL
        return
      end

      html.css('li[data-type="category"]/a.biglist-category').map do |i|
        { name: i.text&.strip, link: absolute_path(i[:href]) }.compact_blank
      end.compact_blank
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

    def product(url, brand_name: nil)
      return if url.blank?
      url = url&.split('#p-')&.first
      html = get_html url

      return if html.blank? || html.at('#cf-error-details').present?

      info = { link: url, brand_name: brand_name }

      info[:title] = html.at('.prod-article/.prod-hgroup/h1/span')&.text&.strip
      info[:name] = html.at('#CurrentSkuContainer/.CurrentSku')&.text&.strip
      info[:description] = html.at('#prod-info/.prod-description/div')&.text&.strip
      info[:old_price] = price_to_i nokogiri_try(html.at('.price-msrp/.price-range/.price-amount'), 'data-value')

      if (price_el = html.at('.prod-page-price')).present?
        info[:price] = price_to_i nokogiri_try(price_el.at('.price-range/.price-amount'), 'data-value')
        info[:price] ||= price_to_i price_el&.css('span')&.last&.text&.strip
        info[:old_price] ||= price_to_i price_el&.css('span')&.first&.text&.strip
      end

      info.delete :old_price if info[:price] == info[:old_price]

      info[:discount] = price_to_i nokogiri_try(html.at('.offer-text/.price-amount'), 'data-value')
      info[:rating] = nokogiri_try(html.at('.prod-stats/a/.stars-wrapper/span'), 'title')&.split(/\s+/)&.second

      if html.at('button.btn-add_to_cart').present? || html.at('.avail-instock')&.text&.downcase&.include?('in stock')
        info[:status] = :active
      else
        info[:status] = :inactive
      end

      #specifications
      filters = %i(shape length country wrapper)

      html.at('.prod-characteristics/div')&.css('.row')&.each do |i|
        key = (i.at('.details-heading') || i.at('div.pr-0'))&.text&.strip&.gsub(/\s+/, '_')&.underscore&.to_sym
        value_node = i.at('.details-div-text/.product-name/.nobreak') || i.at('div.pl-lg-0')

        value = value_node&.text&.strip
        value = nokogiri_try(value_node&.at('img'), 'alt') if value.blank?

        if key.present? && value.present?
          info[key] = value
          info["#{ key }_fltr".to_sym] = value if filters.include?(key)
        end
      end

      #images
      info[:images] = html.css('#products-carousel/.item').map do |i|
        nokogiri_try(i.at('img'), 'src')&.gsub('//', 'https://')
      end.compact_blank

      info[:reviews] = html.at('#prod-reviews-pagination')&.css('.review-ratings')&.map do |review|
        {
          rating: nokogiri_try(review.at('.stars'), 'title')&.split(/\s+/)&.second&.strip&.to_i,
          title: review.at('.feedback-text')&.text&.strip,
          body: review.at('.review-text')&.text&.strip,
          reviewer_name: review.at('.by-name')&.text&.strip,
          review_date: parse_datetime(review.at('.month-text')&.text&.strip)
        }.compact_blank
      end&.compact_blank

      recursive_compact_blank info
    end

    private

    def paginate_list(url, category, brand_name = nil, &block)
      list_page_url = url

      loop do
        html = get_html list_page_url

        break if html.blank? || html.at('#search-noresult').present?

        products_urls = html
                            .css('div.product-text/a.title')
                            .map { |i| absolute_path i[:href] }
                            .compact_blank

        next_page_node = html.css('ul.pagination/li').last&.at('a.page-link')
        list_page_url = next_page_node.present? ? absolute_path(next_page_node[:href]) : nil

        self.instance_exec products_urls, category, brand_name, &block if block.is_a?(Proc) && products_urls.present?

        break if list_page_url.blank?
      end
    end
  end
end

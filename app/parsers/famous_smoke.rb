class FamousSmoke < Parser
  PER_PAGE = 240

  class << self
    def store
      'Famous Smoke'
    end

    def host
      'www.famous-smoke.com'
    end

    def preload_images?
      true
    end

    def user_agent
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6_2; rv:120.0esr) Gecko/20110101 Firefox/120.0esr'
    end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h[:'User-Agent'] ||= user_agent
      @h[:Accept] ||= 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      @h[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @h[:DNT] ||= [0,1].sample
      @h[:Host] ||= host if host.present?
      @h[:Connection] ||= 'keep-alive'
      @h[:'Upgrade-Insecure-Requests'] ||= 1
      @h[:'Sec-Fetch-Dest'] ||= 'document'
      @h[:'Sec-Fetch-Mode'] ||= 'navigate'
      @h[:'Sec-Fetch-Site'] ||= 'cross-site'
      @h[:'Sec-Fetch-User'] ||= '?1'
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
      @ih[:DNT] ||= [0,1].sample
      @ih[:Host] ||= 'images.famous-smoke.com'
      @ih[:Referer] ||= "#{ self.root }/" if self.root.present?
      @ih[:Connection] ||= 'keep-alive'
      @ih[:'Sec-Fetch-Dest'] ||= 'image'
      @ih[:'Sec-Fetch-Mode'] ||= 'no-cors'
      @ih[:'Sec-Fetch-Site'] ||= 'same-site'
      self.instance_exec @ih, &block if block.is_a?(Proc)
      @ih
    end

    def categories_urls
      [
        {
          name: 'Tobacco',
          link: 'https://www.famous-smoke.com/tobacco-search'
        },
        {
          name: 'Cigars',
          link: 'https://www.famous-smoke.com/cigars/premium-cigars'
        },
        {
          name: 'Machine Made Cigars',
          link: 'https://www.famous-smoke.com/cigars/machine-made-cigars'
        },
        {
          name: 'Accessories',
          link: 'https://www.famous-smoke.com/accessories-search'
        }
      ]
    end

    def pagination(&block)
      categories_urls.map do |category|
        cat = find_category category[:name]

        category_url = "#{ category[:link] }?results_per_page=#{ PER_PAGE }"
        page = 1

        loop do
          page_url = category_url
          page_url += "&page_number=#{ page }" if page > 1
          html = get_html page_url

          if html.blank?
            log_error self.name, __method__, page_url
            return
          end

          products_urls = html.css('.dealitembox').map { |l| l['href'] }.compact_blank
          page += 1

          self.instance_exec products_urls, cat, &block if block.is_a?(Proc)

          break if html.css('.pagenumbers/a.btn.notavailable.oswald').any? { |i| i.text&.strip == 'Next' }
        end
      end
    end

    def product(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      item = html.at_css('article#main-item/div.fss-boot')
      return if item.blank?

      info = { link: url }

      info[:title] = item.at('div#current-item-header/h1.title')&.text&.strip
      info[:name] = item.at('div#current-item-pricing/div.subtitle')&.text&.strip
      info[:description] = item.at('div.item-description/p')&.text&.strip
      info[:price] = price_to_i item.at('span.subtitle.itemprice')&.text&.strip
      info[:old_price] = price_to_i item.at('div.col-3/span.itemprice/del')&.text&.strip
      info[:discount] = item.at('div.col-5/span.subtitle.itemprice')&.text&.strip
      info[:rating] = item.at('div.star-rating-display')['data-rating'] if item.at('div.star-rating-display').present?
      info[:brand_name] = html.at('div.breadcrumb/a.link/span')&.text&.gsub('Online for Sale', '')&.strip

      item.css('div#current-item-attributes/div.collapse/div/div').each do |i|
        key = i&.text&.strip&.split(':')&.first&.strip&.gsub(/\s+/, '_')&.underscore&.to_sym
        value = i.at('b')&.text&.strip

        case key
        when :wrapper_origin
          info[:wrapper] = value
        else
          info[key] = value
        end if key.present? && value.present?
      end

      info[:images] = item.css('div.slick/picture/img').map do |img|
        img['data-fullimage'] || img['src']
      end

      info[:images] = [nokogiri_try(item.at('#main-image/img'), 'src')].compact_blank if info[:images].blank?

      reviews_attributes = Yotpo.reviews pid: Yotpo.resource_pid(html),
                                         app_key: 'byYZGLnx30FWEWuEl0hYzRqohEFZBXQVzuzbcSqn',
                                         origin: host,
                                         widget_version: '2023-05-24_17-54-31'

      info.merge! reviews_attributes if reviews_attributes.present?

      recursive_compact_blank info
    end

    def build_attributes(details, except: [])
      _attributes = super(details.except :images)
      _attributes[:title] = [_attributes[:title], _attributes[:name]].compact_blank.join(' | ')

      if details[:images].present? && (except.blank? || !except.include?(:images))
        _attributes[:attachments_attributes] = details[:images].map do |img|
          { attachment: get_image(img, use_proxy: false) }
        end
      end

      recursive_compact_blank _attributes
    end
  end
end

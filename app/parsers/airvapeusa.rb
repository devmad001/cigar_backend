class Airvapeusa < Parser
  class << self
    def host
      'airvapeusa.com'
    end

    def store
      'AirVape'
    end

    def headers(options = {}, &block)
      us = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 '\
            '(KHTML, like Gecko) Chrome/83.0.4103.131 Safari/537.36'

      h = options || {}
      h['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      h['Accept-Language'] = 'en-US,en;q=0.5'
      h['Cache-Control'] = 'max-age=0'
      h['Connection'] = 'keep-alive'
      h['Cookie'] = 'secure_customer_sig=; _orig_referrer=; _landing_page=%2F; '\
                      '_y=1a988ca2-4dde-4697-bbfc-a3ef24a3d6cf; _s=02ff70d8-ccc7-45d2-9d55-0fe28f7601a7; '\
                      '_shopify_y=1a988ca2-4dde-4697-bbfc-a3ef24a3d6cf; _shopify_s=02ff70d8-ccc7-45d2-9d55-0fe28f7601a7; '\
                      '_shopify_sa_t=2021-09-13T13%3A31%3A10.800Z; _shopify_sa_p=; acscurrency=USD; currency=USD'
      h['DNT'] ||= %w(0 1).sample
      h['Host'] ||= host if host.present?
      h['TE'] = 'Trailers'
      h['Referer'] ||= root
      h['Upgrade-Insecure-Requests'] = '1'
      h['User-Agent'] ||= us
      self.instance_exec h, &block if block.is_a?(Proc)
      h
    end

    def categories
      {
        'E-Liquid' => %w(
                        http://airvapeusa.com/collections/replacement-parts
                      ),
        'Devices' => %w(
                        https://airvapeusa.com/collections/dry-herb-vapes
                        https://airvapeusa.com/products/airvape-legacy
                        https://airvapeusa.com/products/airvape-legacy-special-edition
                        https://airvapeusa.com/collections/custom-collection-2
                        https://airvapeusa.com/products/airvape-xs-go
                        https://airvapeusa.com/collections/special-edition-airvape-x
                        https://airvapeusa.com/collections/airvape-x-artist-edition
                        https://airvapeusa.com/collections/airvape-om
                        https://airvapeusa.com/collections/airvape-om
                        https://airvapeusa.com/collections/om-mini
                      )
      }
    end

    def list(url)
      html = get_html url
      return if html.blank?

      html.css('div.collection-products/div/div/div').map do |i|
        item = {}
        item[:link] = "#{ root }#{ nokogiri_try i.at('a'), :href }"
        item[:image] = "https:#{ nokogiri_try i.at('img'), :src }"
        item[:title] = i.at('div.product-collection__title')&.text&.strip
        item[:price] = price_to_i i.at('span.price')&.text&.strip
        item
      end
    end

    def items(url)
      html = get_html url
      return if html.blank?
      html.css('div.collection-products/div/div/div').map do |i|
        "#{ root }#{ nokogiri_try i.at('a'), :href }"
      end
    end

    def product(url)
      if (html = get_html url).blank?
        log_error url
        return
      end

      if (details_block = html.at('div[data-section-id="product"]/div')).blank?
        log_error url
        return
      end

      info = {
        link: url
      }

      if (first_section = details_block.at('.first-section')).present?
        info[:title] = first_section.at('.title')&.text&.strip
        info[:name] = first_section.at('.sub-title')&.text&.strip&.gsub(/\s+/, ' ')
        info[:price] = price_to_i first_section.at('.price')&.text&.strip
        info[:images] = details_block.css('img').map do |i|
          img_link = nokogiri_try i, :src
          img_link =~ /.svg$/ ? nil : img_link
        end.compact
        first_section.remove
      elsif (product_details = details_block.at('.product-page-main')).present?
        info[:title] = product_details.at('h1.h2')&.text&.strip
        info[:price] = price_to_i product_details.at('.price')&.text&.strip
        info[:images] = product_details.at('.product-page-gallery')&.css('img')&.map do |i|
          nokogiri_try(i, 'data-src')&.gsub('//', 'https://')
        end
      end

      if (description_block = details_block.at('div.active/div.tabs__content')).present?
        description_block.css('script').remove
        description_block.css('form').remove
        description_block.css('style').remove
        info[:description] = description_block.content&.strip&.gsub(/\s{2,}/, "\n")
      else
        details_block.css('script').remove
        details_block.css('form').remove
        details_block.css('style').remove
        info[:description] = details_block.text&.strip&.gsub(/\s{2,}/, "\n")
      end

      info.compact
    end

    def pagination(&block)
      parent_category = find_category 'E-Cigarettes'
      self.categories.each do |title, links|
        _category = find_category title, parent_category.id
        links.each do |link|
          if link =~ /\/products\//
            self.instance_exec [link], _category, &block if block.is_a?(Proc)
          else
            next_page = true
            page = 1
            base_url = "#{ link }?page="

            while next_page do
              puts "page: #{ page }".yellow
              next_page = false
              if (_items = items "#{ base_url }#{ page }").present?
                self.instance_exec _items, _category, &block if block.is_a?(Proc)
                next_page = true
                page += 1
              end
            end
          end
        end
      end
    end
  end
end

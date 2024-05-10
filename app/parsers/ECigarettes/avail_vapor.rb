module ECigarettes
  class AvailVapor < Parser
    class << self
      def host
        'availvapor.com'
      end

      def store
        'Avail Vapor'
      end

      def categories
      {
          'Devices' => %w(
                          https://availvapor.com/products/categories/devices-kits-tanks/
                        ),
          'E-Liquid' => %w(
                          https://availvapor.com/products/categories/vape-juice/
                        )
        }
      end

      def list(url)
        html = get_html url
        return if html.blank?
        info = {}
        info[:products] = html
                              .css('.bc-product-card/.bc-product__meta/.bc-product__title/a')
                              .map { |l| l['href'] }
        info[:pages] = pagination_info html
        info
      end

      def pagination_info(html)
        pages_block = html&.at('div.nav-links')
        return if pages_block.blank?
        {
          first: pages_block.css('.page-numbers').first&.text&.gsub('Page', '')&.strip.to_i,
          current: pages_block.at('.page-numbers.current')&.text&.gsub('Page', '')&.strip.to_i,
          last: pages_block.css('.page-numbers')[-2]&.text&.gsub('Page', '')&.strip.to_i
        }
      end

      def product(url)
        html = get_html url
        return if html.blank?

        info = {
          link: url
        }

        info[:description] = html.at('.bc-single-product__description')&.text&.strip
        info[:title] = html.at('.bc-product__title')&.text&.strip
        info[:brand_name] = html.at('.bc-product__brand')&.text&.strip
        info[:price] = price_to_i html.at('.bc-product__price')&.text
        keys = [
          'Dimensions', 'Materials', 'Eliquid Capacity', 'Weight', 'Battery',
          'Charging', 'Wattage Output', 'Resistance', 'Resistance Range', 'Screen',
          'Threading to Tank', 'Primary Flavors', 'Nicotine Content',
          'E-Liquid Content', 'Bottle Sizes', 'Bottle Type'
        ]
        specs = {}
        html.css('.bc-product__description/.gvPara').each do |i|
          key = i.at('span')

          if key.present? && keys.include?(key.text.gsub(':', ''))
            spec_key = key&.text&.strip&.gsub(/\s+/, '_')&.gsub(':', '')&.underscore
            value = i&.text&.gsub(key&.text, '')&.strip
          end
          specs[spec_key] = value if spec_key.present?
        end

        info[:specifications] = specs if specs.present?

        images = html.css('.bc-product-gallery__image-slide/img').map { |item| item['src'] }
        info[:images] = images if images.present?

        info
      end

      def pagination(&block)
        self.categories.each do |title, links|
          _category = find_category title
          links.each do |link|
            next_page = true
            page = 1
            base_url = link

            while next_page do
              puts "page: #{ page }".yellow
              next_page = false
              _items = list "#{ base_url }#{ page != 1 ? "page/#{ page }" : '' }"
              if _items.present? && _items[:products].present?
                self.instance_exec _items[:products], _category, &block if block.is_a?(Proc)
                if _items[:pages].present? && _items[:pages][:current] < _items[:pages][:last]
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
end

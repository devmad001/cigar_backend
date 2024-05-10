module ECigarettes
  class KindJuice < Parser
    class << self
      def host
        'www.kindjuice.com'
      end

      def store
        'Kind Juice'
      end

      def list
        html = get_html 'https://www.kindjuice.com/vape-juice'
        return if html.blank?
        html.css('.product/.inner_product/a').map { |p| p['href'] }
      end

      def product(url)
        html = get_html url
        return if html.blank?

        info = {}
        info[:title] = html.at('.product_title')&.text&.strip
        info[:name] = 'Vape Juice'
        info[:rating] = html.at('.star-rating')['aria-label']&.split(' ')[1]
        info[:description] = html.css('#tab-description/div/span')[1]&.text&.strip if html.css('#tab-description/div/span').present?
        info[:price] = html.at('.price/span')&.text&.strip&.gsub('$','')&.gsub('.', '')&.to_i
        info[:images] = [html.at('.woocommerce-product-gallery__wrapper/div/img')['src']].compact
        specs = {}

        html.css('.woocommerce-product-attributes-item').map do |item|
          key = item.at('th')&.text&.strip&.gsub(/\s+/, '_')&.underscore
          value = item.at('td')&.text&.strip
          specs[key] = value if key.present? && value.present?
        end

        info[:specifications] = specs if specs.present?

        info[:seller] = store
        info[:brand_name] = store
        info[:link] = url

        reviews = html.css('.comment-text').map do |review|
          r = {}
          r[:rating] = review.at('.star-rating')['aria-label']&.split(' ')[1]&.to_i if review.at('.star-rating').present?
          r[:body] = review.at('.description/p')&.text&.strip
          r[:reviewer_name] = review.at('.meta/.woocommerce-review__author')&.text&.strip
          r[:review_date] = review.at('.meta/.woocommerce-review__published-date')['datetime']&.to_datetime
          r.compact!.present? ? r : nil
        end.compact

        info[:reviews] = reviews if reviews.present?
        info
      end

      def pagination(&block)
        main_category = find_category 'E-Cigarettes'
        category = find_category 'E-Liquid', main_category.id

        self.instance_exec list, category, &block if block.is_a?(Proc)
      end
    end
  end
end

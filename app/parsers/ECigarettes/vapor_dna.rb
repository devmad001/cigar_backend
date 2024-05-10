module ECigarettes
  class VaporDna < Parser
    class << self
      def host
        'vapordna.com'
      end

      def store
        'VaporDNA'
      end

      def pagination(&block)
        main_category = find_category 'E-Cigarettes'

        list.each do |category|
          cat = find_category category[:name], main_category.id

          self.instance_exec category[:links], cat, &block if block.is_a?(Proc)
        end
      end

      def product(product)
        info = fields product
        info[:reviews] = reviews(product['id'])
        info[:old_price] = product['compare_at_price'] * 100 if product['compare_at_price'].present?
        if product['meta'].present? && product['meta']['stamped']['reviews_average'].present?
          info[:rating] = product['meta']['stamped']['reviews_average'].to_f.ceil(1)
        end
        info[:images] = [ product['product_image'] ] if product['product_image'].present?
        info
      end

      def find_product(link)
        @products_list ||= list
        @products_list.each do |category|
          product = category[:links].find { |pr| link == 'https://vapordna.com/products/' + pr['handle'] }
          return product(product) if product.present?
        end
      end

      private

      def list
        ECigarettes::VaporDnaList.call
      end

      def fields(product)
        {
          title: product['title'],
          name: product['sku'],
          link: 'https://vapordna.com/products/' + product['handle'],
          description: product['body_html_safe'],
          price: product['price'] * 100,
          brand_name: product['vendor'],
          seller: 'VaporDNA'
        }
      end

      def reviews(id)
        h = {}
        h[:Connection] = 'keep-alive'
        h['Content-type'] = 'application/json'
        h['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0'
        h[:Host] = '5veqgaeor7-3.algolianet.com'
        h[:Origin] = 'https://vapordna.com'
        h[:Referer] = 'https://vapordna.com'
        link = "https://stamped.io/api/widget?productId=#{ id }&apiKey=pubkey-KtobpP2Re1Cj386Oedm4BFXMZ1BYCE&sId=79578&take=50&sort=featured"
        response = JSON.parse(RestClient.get(link, h))

        parse_reviews(response['widget']) if response.present?
      end

      def parse_reviews(widget)
        html = Nokogiri::HTML(widget)
        reviews = []
        html.css('.stamped-review').each do |review|
          r = {}
          r[:rating] = review.at('.stamped-review-header/.stamped-starratings')["data-rating"]&.to_i
          r[:title] = review.at('.stamped-review-content/.stamped-review-body/.stamped-review-header-title')&.text&.strip
          r[:body] = review.at('.stamped-review-content/.stamped-review-body/.stamped-review-content-body')&.text&.strip
          r[:reviewer_name] = review.at('.stamped-review-header/.author')&.text&.strip
          r[:review_date] =  DateTime.strptime(review.at('.stamped-review-header/.created')&.text&.strip, '%m/%d/%Y')

          reviews.push(r)
        end
        reviews
      end
    end
  end
end

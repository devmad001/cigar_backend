module ECigarettes
  class VaporDnaList < VaporDna
    class << self
      def call
        parse
      end

      private

      def categories_urls
        [
          {
            category: 'Devices',
            pages: 3,
            filters: "collections%3A%22vape-devices%22&ruleContexts=%5B%22vape-devices%22%5D&"\
                      "facets=%5B%22options.color%22%2C%22price%22%2C%22price_range%22%2C%22vendor%22%2C%22"\
                      "options.nicotine_level%22%2C%22product_type%22%2C%22tags%22%2C%22options.size%22%5D"
          },
          {
            category: 'E-Liquid',
            pages: 4,
            filters: "collections%3A%22e-liquids%22&ruleContexts=%5B%22e-liquids%22%5D&facets=%5B%22"\
                      "options.color%22%2C%22price%22%2C%22price_range%22%2C%22vendor%22%2C%22"\
                      "options.nicotine_level%22%2C%22product_type%22%2C%22tags%22%2C%22options.size%22%5D&tagFilters="
          },
          {
            category: 'Accessories',
            subcategory: true,
            pages: 7,
            filters: "collections%3A%22accessories%22&ruleContexts=%5B%22accessories%22%5D&facets=%5B%22"\
                      "options.color%22%2C%22price%22%2C%22price_range%22%2C%22vendor%22%2C%22"\
                      "options.nicotine_level%22%2C%22product_type%22%2C%22tags%22%2C%22options.size%22%5D&tagFilters="
          },
        ]
      end

      def parse
        links = []
        link = 'https://5veqgaeor7-3.algolianet.com/1/indexes/*/queries?x-algolia-agent=Algolia'\
                '%20for%20vanilla%20JavaScript%20(lite)%203.27.1%3Binstantsearch.js'\
                '%201.12.1%3BJS%20Helper%202.26.0&x-algolia-application-id=5VEQGAEOR7&'\
                'x-algolia-api-key=264c32e27e96824297a1a886f625b1f5'
        categories_urls.each do |category|
          (0..category[:pages]).map do |page|
            links << {
              name: category[:category],
              links: products(link, page, category[:filters])
            }
          end
        end

        links
      end

      def products(link, page, filters)
        h = {}
        h[:Connection] = 'keep-alive'
        h['Content-type'] = 'application/json'
        h['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0'
        h[:Host] = '5veqgaeor7-3.algolianet.com'
        h[:Origin] = 'https://vapordna.com'
        h[:Referer] = 'https://vapordna.com'

        response = JSON.parse(RestClient.post(link, payload(page, filters), h))['results'][0]['hits']
        response
      end

      def payload(page, filters)
        {
          requests: [
            {
              indexName: 'shopify_products',
              params: "query=&hitsPerPage=100&maxValuesPerFacet=50&page=#{ page }&highlightPreTag=%3Cspan%20"\
                        "class%3D%22ais-highlight%22%3E&highlightPostTag=%3C%2Fspan%3E&distinct=true"\
                        "&clickAnalytics=true&filters=#{ filters }"
            }
          ]
        }.to_json
      end
    end
  end
end

class Blu < Parser
  class << self
    URL_PARTS = {
      'bluLiquidpod' => 'myblu-liquidpods',
      'bluPlusCartridge' => 'blu-plus-tanks',
      'bluDisposable' => 'blu-disposable',
      'bluELiquid' => '',
      'accessory' => 'accessories',
      'device' => 'e-cigs',
      'flavor' => 'flavors',
      'starterKit' => 'e-cigs'
    }

    PRODUCT_FIELDS = %w(
                        key
                        flavorSystemType
                        productType
                        introText
                        flavorName
                        vegetableGlycerinLevel
                        propyleneGlycolLevel
                        flavorCollectionType
                        variantDiscriminator
                        slug
                        nicotinePercentage
                        nicotineMgPerMl
                        flavorType
                      )

    def host
      'www.blu.com'
    end

    def store
      'Blu'
    end

    def headers(options = {}, &block)
      us = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.131 Safari/537.36'

      h = options || {}
      h['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      h['Accept-Language'] = 'en-US,en;q=0.5'
      h['Cache-Control'] = 'max-age=0'
      h['Connection'] = 'keep-alive'
      h['Cookie'] = 'accepted_legal_age_v2_US=1; accessTokenUS=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IjI3ZmY2MmM1LTZmYWEtNGQ4Yi05YTQ1LTkyZDcxNmU3YjNkNiIsInJvbGUiOiJHdWVzdCIsIm5iZiI6MTYyODg0Nzk4MywiZXhwIjoxNjI4ODQ5NzgzLCJpYXQiOjE2Mjg4NDc5ODN9.BECvhdroBFHTA-xqe5Pjz_J0H3-Ow4atm-pIVFDpqXw; akaalb_bluAP-prod=~op=AP_www_blu_com_US_ONLY_LBG:Azure-AP-Prod-US|~rv=23~m=Azure-AP-Prod-US:0|~os=86a835fd08c2120ce5961211bd34dd2c~id=adaa346092cebf1e85b403d79b053f8e; _dd_s=rum=1&id=bd903e30-0dd0-48f7-8abf-bf7ba53c8908&created=1628847215600&expire=1628848931300; AKA_A2=A; cartTokenUS=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6IjI3ZmY2MmM1LTZmYWEtNGQ4Yi05YTQ1LTkyZDcxNmU3YjNkNiIsIkNhcnRJZCI6Ijc1MjljYTI0LTk5YzAtNGU4OC1hZGZkLTdkMTI5NWJlMjdmOCIsIkNhcnRWZXJzaW9uIjoiMjYiLCJDYXJ0VHlwZSI6IkN1c3RvbWVyIiwibmJmIjoxNjI4ODQ3OTgzLCJleHAiOjE2Mjg4NTE1ODMsImlhdCI6MTYyODg0Nzk4M30.c1Ykxq9GsnIRjv3Ba9wjalviTNTAeRZ5fDxrhAEPlMA'
      h['DNT'] ||= %w(0 1).sample
      h['Host'] ||= host if host.present?
      h['If-None-Match'] = 'W/"2ee3d-/c7SjTSF05T8nkOGvoGclZsRqPs"'
      h['Referer'] ||= root
      h['Upgrade-Insecure-Requests'] = '1'
      h['User-Agent'] ||= us
      self.instance_exec h, &block if block.is_a?(Proc)
      h
    end

    def categories_urls
      [
        {
          category: 'blu® Devices',
          link: 'https://www.blu.com/en/US/myblu',
          key: 'e-cigs',
          page_type: :list
        },
        {
          category: 'Pods',
          link: 'https://www.blu.com/en/US/blu-liquidpods',
          key: 'flavors/myblu-liquidpods',
          page_type: :list
        },
        {
          category: 'blu® Disposable',
          link: 'https://www.blu.com/en/US/flavors/blu-disposable',
          key: 'blu-disposable',
          page_type: :list
        },
        {
          category: 'blu PLUS+®',
          link: 'https://www.blu.com/en/US/e-cigs/blu-plus-xpress-kit-1-us',
          key: 'blu-plus-xpress-kit-1-us',
          page_type: :product
        },
        {
          category: 'Tanks',
          link: 'https://www.blu.com/en/US/flavors/blu-plus-tanks',
          key: 'blu-plus-tanks',
          page_type: :list
        },
        {
          category: 'Accessories',
          link: 'https://www.blu.com/en/US/accessories',
          key: 'accessories',
          page_type: :list
        }
      ]
    end

    def list(url)
      html = get_html url
      return if html.blank?
      data = page_data page: html
      return if data.blank?
      products = data
                     .dig(*%w(props pageProps content sections))
                     .select { |i| i['products'].present? }
                     .map { |i| i['products'] }.flatten

      products = data.dig(*%w(props pageProps flavors)) if products.blank?
      products ||= []

      products.map do |i|
        info = i.slice(*(%w(description) + PRODUCT_FIELDS))
        info[:title] = i['name']
        info[:name] = i['metaTitle']
        info[:images] = i['variants']&.first&.dig(*%w(images pdpCarousel))&.map { |i| i['url'] }
        info[:price] = price_to_i i['variants']&.first&.dig('prices')&.first&.dig(*%w(nowPrice amount)).to_s
        _product_type = URL_PARTS[info['productType']]
        _link = "#{ root }/en/US/#{ _product_type }"
        _flavor_system_type = URL_PARTS[info['flavorSystemType']]
        if _flavor_system_type.present? && %w(accessories e-cigs).exclude?(_product_type)
          _link += "/#{ _flavor_system_type }"
        end
        _link += "/#{ info['key'] }"
        info[:link] = _link
        info[:reviews] = reviews page_data(url: _link)
        info.symbolize_keys
      end
    end

    def product(url)
      html = get_html url
      return if html.blank?
      info = {}
      details_block = html.at('div[data-testid="productDetailsBlock"]')
      return if details_block.blank?

      info[:title] = details_block.at('h1[data-testid="details-product-title"]')&.text&.strip
      info[:description] = details_block.at('div[data-testid="details-product-description"]')&.text&.strip
      info[:price] = price_to_i details_block.at('div[data-testid="details-product-price"]/h4')&.text&.strip

      data = page_data page: html
      _product = data.dig *%w(props pageProps product)
      info[:images] = _product.dig(*%w(images pdpCarousel)).map { |img| img['url'] }
      info[:uspList] = _product['uspList']
      info[:name] = _product['metaTitle']
      info[:link] = url
      info[:reviews] = reviews data
      info.merge(_product.slice(*PRODUCT_FIELDS)).symbolize_keys.compact
    end

    def page_data(url: nil, page: nil)
      return if url.blank? && page.blank?
      html = page.present? ? page : get_html(url)
      return if html.blank?
      JSON.parse html.at('script[id="__NEXT_DATA__"]')&.text
    rescue => e

    end

    def reviews(page)
      page.dig(*%w(props pageProps reviews))&.map do |i|
        {
          title: i['title'],
          body: i['message'],
          rating: i['rating'],
          review_date: Time.at(i['submissionTimestamp']).to_datetime,
          reviewer_name: i.dig(*%w(author nickName))
        }
      end
    end

    def pagination(&block)
      # NOT IMPLEMENTED
    end

    def each_products(type: :all, &block)
      _category = find_category 'Devices'
      categories_urls.each do |category|
        if category[:page_type] == :list
          list(category[:link])&.each do |_product|
            self.instance_exec _product, _category, &block if block.is_a?(Proc)
          end
        else
          self.instance_exec product(category[:link]), _category, &block if block.is_a?(Proc)
        end
      end
    end

    def build_attributes(details)
      _attributes = super
      _attributes[:specifications] = details.except(
        *(CANONICAL_FIELDS + %i(images flavorSystemType productType slug flavorType key parse_type reviews))
      )
      _attributes
    end

    def store_reviews!
      each_products do |details, category|
        _product = Product.find_by link: details[:link]
        if _product.present?
          if details[:reviews].present?
            _product.reviews_attributes = details[:reviews]
            _product.save
          end
        else
          store_product! details, category: category
        end
      end
    end
  end
end

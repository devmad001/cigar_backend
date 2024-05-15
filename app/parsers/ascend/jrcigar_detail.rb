module Ascend
  class JrCigarDetails < Parser
    class << self
      def product(url, brand_name = nil, product_type = nil)
        html = get_html url

        if html.blank?
          log_error self.name, __method__, url
          return
        end

        info = {
          link: url,
          brand_name: brand_name,
          product_type: product_type
        }

        info[:description] = html.at('div.item-description')&.text&.strip
        info[:title] = html.at('div.col-sm-9.page-item/h1.tight')&.text&.strip
        info[:name] = html.at('div.col-sm-9.page-item/h3[itemprop="name"]')&.text&.strip
        info[:price] = html.at('.jr-price/span')&.text&.gsub('$', '')&.gsub('.', '')&.to_i
        info[:old_price] = html.at('.msrp-price/span')&.text&.gsub('$', '')&.gsub('.', '')&.to_i

        if html.at('button.addtocart-button').present?
          info[:status] = :active
        else
          info[:status] = :inactive
        end

        filters = %i(shape strength)

        html.css('div.cigar-details/div/div/div.col-sm-4').each do |item|
          key = item.at('label.control-label')&.text&.strip&.gsub(/\s+/, '_')&.underscore&.to_sym
          value = item.at('div.col-xs-7/p.form-control-static')&.text&.strip

          if key.present? && value.present?
            info[key] = value
            info["#{ key }_fltr".to_sym] = value if filters.include?(key)
            info[:country_fltr] = value if key == :origin
            info[:wrapper_fltr] = value if key == :wrapper_type
          end
        end

        if (yotpo_widget = Yotpo.widget_block html).present? &&
            (pid = yotpo_widget['data-product-id']).present? &&
            (app_key = yotpo_widget['data-appkey']).present?
          reviews_attributes = Yotpo.reviews pid: pid,
                                            app_key: app_key,
                                            origin: root,
                                            widget_version: '2023-07-05_08-43-33',
                                            rating: false

          info.merge! reviews_attributes if reviews_attributes.present?

          info[:rating] = Yotpo.rating pid: pid,
                                      app_key: app_key,
                                      origin: root,
                                      widget_version: '2023-07-05_08-43-33'
        end

        info[:images] = html.css('button.img-thumb/img')&.map do |img|
          URI.encode img['data-imghires']&.strip.to_s
        end.compact_blank

        recursive_compact_blank info
      end
      def build_attributes(details)
      _attributes = super
      _attributes[:title] = [_attributes[:title], _attributes[:name]].compact_blank.join(' | ')
      _attributes.compact_blank
    end

    private

    def parse_brands(url)
      html = get_html url

      if html.blank?
        log_error self.name, __method__, url
        return
      end

      html.css('.brands-list-content/p/.link-bare.bold').map do |l|
        { name: l&.text&.strip, link: l['href'] }.compact_blank
      end.compact_blank
    end

    def parse_products(brand, category: nil, &block)
      products = []
      page = 0

      while true
        puts "page: #{ brand } #{ page + 1 }".yellow

        ps = product_parser brand, page
        break if ps.blank?
        products += ps
        page += 1

        self.instance_exec ps, category, &block if block.is_a?(Proc)
      end

      products.compact_blank
    end

    def product_parser(brand, page)
      html = get_html brand[:link] + "?sz=#{ PER_PAGE }&start=#{ PER_PAGE * page.to_i }"

      if html.blank?
        log_error self.name, __method__, brand[:link]
        return
      end

      type = html.at('#bc_2/a/span')&.text&.strip

      html.css('.item-link/.product-tile-link').map do |l|
        {
          link: 'https://www.jrcigars.com' + l['href'],
          brand_name: brand[:name].gsub("'", ''),
          product_type: type
        }.compact_blank
      end.compact_blank
    end
      private

      def get_options(product_id)
        url = 'https://www.cigarpage.com/grouped_loader/ajax/getItems/'
        uri = URI.parse(url)

        proxy = Net::HTTP::Proxy 'zproxy.lum-superproxy.io',
                                 22225,
                                 'lum-customer-c_c2becd9e-zone-data_center-country-us',
                                 'f9cko0bac6pp'

        h = {}
        h['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        h['Accept-Language'] = 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7'
        h['Connection'] = 'keep-alive'
        h['Content-Length'] = '52'
        h['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        h['Host'] = 'www.cigarpage.com'
        h['Origin'] = 'https://www.cigarpage.com'
        h['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.115 Safari/537.36 OPR/88.0.4412.53'
        h['X-Requested-With'] = 'XMLHttpRequest'

        payload = {
          product_id: product_id,
          deal_salable: -1,
          preview: 0,
          counter: 0
        }
        begin
          req = Net::HTTP::Post.new(uri, h)
          req.set_form_data(payload)

          resp = proxy.start uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE do |http|
            http.request req
          end
          text = Nokogiri::HTML(JSON.parse(resp.body)['html'].strip)
          return nil if text.blank?
          text.css('tr')
        rescue => e
          log_error e.message
        end
      end
    end
  end
end

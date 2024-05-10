module Ascend
  class CigarPageDetails < Parser
    class << self
      def product(url)
        html = get_html url
        return if html.blank? || html.at("#cf-error-details").present?

        info = {}
        filters = %i(wrapper strength shape country)

        if html.at('#product_addtocart_form').present?
          product_id = html.at('#product_addtocart_form')['action']&.split('/product/')&.last&.split('/')&.first
          options = get_options(product_id)
        end

        info[:products] = options.map do |i|
          option = {}
          option[:title] = i.at('.cigar-alt-name')&.text&.strip
          option[:type] = i.css('td')[1].at('span')&.text&.strip
          option[:stock] = i.css('td')[2].at('span')&.text&.strip
          option[:price] = price_to_i i.css('td')[3].at('.price')&.text
          option[:old_price] = price_to_i i.css('td')[3].at('.msrp/.strikethrough/span')&.text
          if option[:price].present? && option[:old_price].present?
            option[:discount] = (100 - (option[:price]/(option[:old_price]/100))).round.to_s + '%'
          end
          option_id = nokogiri_try(i.css('td').last.at('.input-group-btn/button'), 'data-productid')
          option[:link] = url + "##{option_id}"

          # specifications
          i.css('.cigar-attr-row').each do |spec|
            key = spec.at('.cigar-attr-label')&.text&.strip&.downcase&.to_sym
            key = :country if key == :origin
            value = spec.at('.cigar-attr-value')&.text&.strip&.downcase&.gsub(/[()]+/, '')

            if key == :strength
              num_value = nokogiri_try(spec.at('.progress/div'), 'aria-valuenow')&.to_i
              value = num_value > 50 ? 'Full' : 'Mild'
            end

            if key.present? && value.present?
              option[key] = value
              option["#{ key }_fltr".to_sym] = value if filters.include?(key)
            end
          end
          option.compact
        end.compact if options.present?

        reviews = []
        reviews_text = html.at('#customer-reviews-list')
                         &.text
                         &.split("\n")
                         &.map { |i| i.strip }
                         &.reject { |i| i == '' || i == 'Customer Reviews' }
                         &.each_slice(3)
                         &.to_a

        ratings = html.at('#customer-reviews-list')&.css('input')&.map { |i| nokogiri_try(i, 'value')&.to_i }
        reviews_text.each_with_index do |r, i|
          review = {}
          if r&.last.include?('Review by') && r&.length == 3 && ratings[i-1].present?
            review[:rating] = ratings[i-1] / 20
            review[:title] = r&.first
            review[:body] = r&.second
            review[:reviewer_name] = r&.last&.split(' ')&.third
            review[:review_date] = Date.strptime(r&.last&.split(' ')&.last, '%m/%d/%Y')
            reviews.push(review)
          end
        end if ratings.present?

        info[:reviews_attributes] = reviews
        info
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

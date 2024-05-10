module Ascend
  class BestCigarDetails < Parser
    class << self
      def product(url)
        url = url.gsub('http://', 'https://')
        html = Nokogiri.HTML(get_page(url))
        return 'error' if html.blank? || html.at("#cf-error-details").present?

        info = {}

        info[:rating] = html.css('.reviews.avg-review/.glyphicon-star').count

        #specifications
        filters = %i(shape length origin wrapper strength)

        html.at('table.attribute-styled')&.css('tr')&.each do |i|
          key = i.at('.attribute-key')&.text&.strip&.downcase&.to_sym
          value = i.at('.attribute-value')&.text&.strip

          if key.present? && value.present? && filters.include?(key)
            key = :country if key == :origin
            info[key] = value
            info["#{ key }_fltr".to_sym] = value
          end
        end

        reviews = []
        html.at('#reviews')&.css('.review-each').each do |review|
          r = {}
          r[:rating] = review.css('.glyphicon.glyphicon-star')&.count
          r[:title] = review.at('h4')&.text&.strip
          r[:body] = review.css('p')[0]&.text&.strip
          reviewer = review.css('p')[1]
          r[:reviewer_name] = reviewer.css('span')[0]&.text&.strip
          r[:review_date] = DateTime.parse(reviewer.css('span')[1]&.text&.strip)
          reviews.push(r)
        end if html.at('#reviews').present?

        info[:reviews_attributes] = reviews

        info
      end

      private

      def get_page(url)
        uri = URI.parse(url)

        proxy = Net::HTTP::Proxy 'zproxy.lum-superproxy.io',
                                 22225,
                                 'lum-customer-c_c2becd9e-zone-data_center-country-us',
                                 'f9cko0bac6pp'

        h = {}
        h['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        h['authority'] = 'www.bestcigarprices.com'
        h['cookie'] = '_vuid=51a0701e-a2bf-4d71-a209-eb1dd1ef0c68; cookie_cart_login=0; ltkSubscriber-Account=eyJsdGtDaGFubmVsIjoiZW1haWwiLCJsdGtUcmlnZ2VyIjoibG9hZCJ9; ltkSubscriber-Footer=eyJsdGtDaGFubmVsIjoiZW1haWwiLCJsdGtUcmlnZ2VyIjoibG9hZCIsImx0a0VtYWlsIjoiIn0%3D; _wingify_pc_uuid=aba360fc80cd4d75b86a3a8c1bd995dc; GSIDsNOgpdeOrS4Q=b2a68d56-91f9-4f4e-9931-8246fe278e5d; STSID850749=fca53269-7e3a-42f4-b7d8-29965b1af7ae; hw_uuid=82562728f5ae45eab5c829e843876d31; _vt_shop=1363; _vt_user=7751553410446327_504406741044683733_false_false; wingify_donot_track_actions=0; _hjSessionUser_337611=eyJpZCI6IjVmOTVjZjI2LWFjZmEtNTY2Ny04ZTZlLThiMTRkYmYyZDdiYyIsImNyZWF0ZWQiOjE2NTM3NDQ4NTM5OTIsImV4aXN0aW5nIjp0cnVlfQ==; ltkpopup-suppression-fae7c01d-1af6-467f-a082-ba6cd7996de2=1; comm100_visitorguid_1000443=346a04b3-dfae-4d2c-8164-6dde18b1b6a3; pjn-click=[{"id":"4011831667","days":19171,"type":"p"},{"id":"4014788294","days":19174,"type":"p"}]; cf_clearance=hfTr2cphsrIWvrixT7eM.ral3FYLMhDh9.luNGibmSw-1657112549-0-150; PHPSESSID=23p2v4lv62jeoo4g1dqhkef8h9; test-cookie=1; cart_items=true; ltkpopup-session-depth=7-2; _gid=GA1.2.1668230256.1659433156; _gat=1; __cf_bm=jAi1j4DBrRicZTF2q0OOBrYMX2LXeU8D30OYmdq7uXw-1659433156-0-AQvmGBxVVKLFoGjEATgydIz25DL9SZQ3FJGfz6f+pJrTuRhSUxlYs6ABiRuhJ+XsfiRTbuLsDysxmmuzbiCToMeskVLqw5nl+yRMcFRHSe88vE8zj5DZRoI+sRVloIprMA==; _ga_72KR0PQCFV=GS1.1.1659433156.11.0.1659433156.0; _ga=GA1.1.1757013073.1653744820; _hjIncludedInSessionSample=1; _hjSession_337611=eyJpZCI6ImNmOGVmZWRkLWY3ZGUtNGQ3Yy1hNjIwLTNlMGFhNmIyZWQ2NyIsImNyZWF0ZWQiOjE2NTk0MzMxNTg1OTgsImluU2FtcGxlIjp0cnVlfQ==; _hjIncludedInPageviewSample=1; _hjAbsoluteSessionInProgress=1; CYB_ID=7751553410446327; c_64ei=ZmFsc2U=; addshoppers.com=2%7C1%3A0%7C10%3A1659433163%7C15%3Aaddshoppers.com%7C44%3AODA2OGVmNGVkM2E0NDM2OGE5MmZjODNlYzk2MGY2YzM%3D%7C6e7bac79aee1f24a5bea549077a6a29344214f826241f6b49a95a10918e53f6f'
        h['Connection'] = 'keep-alive'
        h['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
        h['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.5005.115 Safari/537.36 OPR/88.0.4412.53'

        begin
          req = Net::HTTP::Get.new(uri, h)

          resp = proxy.start uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_NONE do |http|
            http.request req
          end
          resp.body
        rescue => e
          log_error e.message
        end
      end
    end
  end
end

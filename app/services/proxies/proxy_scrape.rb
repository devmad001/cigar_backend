module Proxies
  class ProxyScrape < BaseParser
    UPDATE_INTERVAL = 5.minutes

    class << self
      def host
        'api.proxyscrape.com'
      end

      def use_proxy
        false
      end

      # protocol: http/https/socks4/socks5/all
      # timeout: 10000
      # country: all
      # ssl: all/yes/no
      # anonymity: elite/anonymous/transparent/all
      def get_proxies(protocol: 'all', timeout: 100, ssl: 'yes', anonymity: 'elite')
        base_url = 'https://api.proxyscrape.com/v2/?request=displayproxies'

        params = {
          protocol: protocol,
          timeout: timeout,
          ssl: ssl,
          anonymity: anonymity
        }.compact_blank

        base_url += '&' + params.to_query
        resp = get_resp base_url
        return [] if resp.code >= 400
        resp.body&.split(/\s+/).compact.uniq
      end

      def https_proxies
        if @https_proxies.blank? || @https_proxies_get_at.blank? || @https_proxies_get_at < UPDATE_INTERVAL.ago
          proxies = get_proxies protocol: 'https'

          if proxies.present?
            @https_proxies_get_at = Time.now
            @https_proxies = proxies
          end
        else
          @https_proxies
        end
      end

      def https_proxy_options
        proxy_item = https_proxies&.sample
        "https://#{ proxy_item }" if proxy_item.present?
      end

      def socks4_proxies
        if @socks4_proxies.blank? || @socks4_proxies_get_at.blank? || @socks4_proxies_get_at < UPDATE_INTERVAL.ago
          proxies = get_proxies protocol: 'socks4'

          if proxies.present?
            @socks4_proxies_get_at = Time.now
            @socks4_proxies = proxies
          end
        else
          @socks4_proxies
        end
      end

      def socks4_proxy_options
        proxy_item = socks4_proxies&.sample
        "socks://#{ proxy_item }" if proxy_item.present?
      end

      def socks5_proxies
        if @socks5_proxies.blank? || @socks5_proxies_get_at.blank? || @socks5_proxies_get_at < UPDATE_INTERVAL.ago
          proxies = get_proxies protocol: 'socks5'

          if proxies.present?
            @socks5_proxies_get_at = Time.now
            @socks5_proxies = proxies
          end
        else
          @socks5_proxies
        end
      end

      def socks5_proxy_options
        proxy_item = socks5_proxies&.sample
        "socks5://#{ proxy_item }" if proxy_item.present?
      end

      def proxy_options
        socks5_proxy_options || socks4_proxy_options || https_proxy_options
      end

      def proxy_info!
        @proxy_info = get_json('https://api.proxyscrape.com/v2/?request=proxyinfo').deep_symbolize_keys
      end

      def proxy_info
        @proxy_info || proxy_info!
      end
    end
  end
end

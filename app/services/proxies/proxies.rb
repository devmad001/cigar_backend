module Proxies
  class Proxies
    PROXIES = [TorProxy, Brightdata].freeze

    class << self
      def default
        TorProxy
      end

      def reserve
        Brightdata
      end

      def proxy(i = 0)
        PROXIES[i] || reserve
      end
    end
  end
end

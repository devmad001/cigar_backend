module Proxies
  class Brightdata
    class << self
      def proxy_options
        return @result if @result.present?
        @result = 'https://'
        @result += ENV['PROXY_USER'] if ENV['PROXY_USER'].present?
        @result += ":#{ ENV['PROXY_PASSWORD'] }" if ENV['PROXY_USER'].present? && ENV['PROXY_PASSWORD'].present?
        @result += '@' if ENV['PROXY_USER'].present?
        @result += ENV['PROXY_HOST'] if ENV['PROXY_HOST'].present?
        @result += ":#{ ENV['PROXY_PORT'] }" if ENV['PROXY_PORT'].present?
        @result
      end

      def error_message
        '407 "Account is suspended"'
      end
    end
  end
end

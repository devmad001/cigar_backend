require 'user_agent_randomizer'
require 'nokogiri'
require 'rest-client'
require 'base64'
require 'json'
require 'uri'
require 'openssl'

module URI
  def self.valid?(uri, schemes = %w(http https))
    !(uri =~ /\A#{URI::regexp(schemes)}\z/).nil?
  end
end

class BaseParser
  class << self
    include LogHelper
    include UriHelper
    include HttpRequestHelper

    CANONICAL_FIELDS = Product.column_names.map(&:to_sym)

    def host; end

    def root
      "https://#{ host }" if host.present?
    end

    def absolute_path(path)
      return unless path.is_a?(String)
      absolute_path?(path) ? path : URI.join(self.root, path).to_s
    end

    def absolute_path?(path)
      (path =~ /^https?:\/\/\S+/).present?
    end

    def relative_path?(path)
      !absolute_path?(path)
    end

    def user_agent
      UserAgentRandomizer::UserAgent.fetch(type: :desktop_browser).string
    end

    def headers(options = {}, &block)
      if @h.present?
        return @h.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @h = options || {}
      @h['User-Agent'.to_sym] ||= user_agent
      @h[:DNT] ||= [0,1].sample
      @h[:Host] ||= self.host if self.host.present?
      @h[:Origin] ||= self.root if self.root.present?
      self.instance_exec @h, &block if block.is_a?(Proc)
      @h
    end

    def image_headers(options = {}, &block)
      if @ih.present?
        return @ih.merge(options.is_a?(Hash) ? options.compact_blank : {})
      end

      @ih = options || {}
      @ih[:'User-Agent'] ||= user_agent
      @ih[:Accept] ||= 'image/webp,*/*'
      @ih[:'Accept-Language'] ||= 'en-US,en;q=0.5'
      @ih[:DNT] ||= [0,1].sample
      @ih[:Host] ||= self.host if self.host.present?
      @ih[:Referer] ||= self.root if self.root.present?
      @ih[:Connection] ||= 'keep-alive'
      self.instance_exec @ih, &block if block.is_a?(Proc)
      @ih
    end

    def sample_headers
      { 'User-Agent': user_agent }
    end

    def decode(string)
      if string && (string.encoding.name.index('Windows-1251') || !string.valid_encoding?)
        string.encode('UTF-8', 'windows-1251')
      else
        string
      end
    end

    def use_proxy
      true
    end

    def proxy
      @proxy_index ||= 0
      Proxies::Proxies.proxy(@proxy_index)&.proxy_options
    end

    def next_proxy!
      @proxy_index ||= 0
      @proxy_index += 1
      @proxy_index %= Proxies::Proxies::PROXIES.count
    end

    def nokogiri_try(element, key)
      return if element.blank?
      element.try :[], key
    end

    def price_to_i(str)
      return if str.blank? || !str.is_a?(String)
      str.gsub(/[$.,]/, '').strip.to_i
    end

    def parse_datetime(str, pattern: nil)
      return if str.blank? || !str.is_a?(String)

      if pattern.present?
        DateTime.strptime str, pattern
      else
        DateTime.parse str if str.is_a?(String)
      end
    rescue => e
      log_error self.name, __method__, error: e.message, str: str
    end

    def compact_spaces(str)
      return str unless str.is_a?(String)
      str
          .strip
          .gsub(/(\n+)/, "\n")
          .gsub(/(\t+)/, "\t")
          .gsub(/(\s+)\n(\s+)/, '')
    end

    def recursive_compact_blank!(object)
      object.compact_blank! if object.respond_to?(:compact_blank!)
      object.compact! if object.respond_to?(:compact!)

      if object.is_a?(Array)
        object.each do |i|
          recursive_compact_blank! i
        end
      elsif object.is_a?(Hash)
        object.each do |k, v|
          recursive_compact_blank! v
        end
      elsif object.is_a?(String)
        object.strip!
      end
    end

    def recursive_compact_blank(object)
      _object = object
      _object = _object.compact_blank if _object.respond_to?(:compact_blank)
      _object = _object.compact if _object.respond_to?(:compact)

      if _object.is_a?(Array)
        _object.map do |i|
          recursive_compact_blank i
        end.compact_blank
      elsif _object.is_a?(Hash)
        obj = {}

        _object.each do |k, v|
          nv = recursive_compact_blank v
          obj[k] = nv if nv.present?
        end

        obj.compact_blank
      elsif _object.is_a?(String)
        _object.strip
      else
        _object
      end
    end

    def one_line_str(str)
      return str unless str.is_a?(String)
      str.gsub(/(\s+)/, ' ')
    end
  end
end

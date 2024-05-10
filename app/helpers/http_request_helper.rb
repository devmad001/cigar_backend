module HttpRequestHelper
  RETRY_COUNT = 3

  def get_resp(url, options = {})
    request = {
      method: options[:method] || :get,
      url: url,
      verify_ssl: options[:verify_ssl] || OpenSSL::SSL::VERIFY_NONE
    }

    request[:headers] = options[:headers] if options[:headers]
    request[:headers] ||= headers if request[:headers].nil? && self.respond_to?(:headers)

    %i(proxy payload).each do |option|
      request[option] = options[option] if options[option].present?
    end

    if options[:query].present?
      _query = options[:query]
      _query = _query.to_query if _query.is_a?(Hash)
      u = URI.parse request[:url]
      u.query = [u.query, _query].compact_blank.join '&'
      request[:url] = u.to_s
    end

    result = nil
    try_count = 0
    retry_count = options[:retry_count] || RETRY_COUNT
    request_errors = []

    while result.nil? && try_count < retry_count
      if options[:use_proxy] != false && self.respond_to?(:use_proxy) &&
          use_proxy && options[:proxy].blank? && self.respond_to?(:proxy)
        request[:proxy] = proxy
      end

      begin
        result = RestClient::Request.execute **request
      rescue => e
        next_proxy! if request[:proxy] && respond_to?(:next_proxy!)
        try_count += 1
        request_errors << e

        if try_count >= retry_count && (e.message.include?('403') || e.message.downcase.include?('forbidden'))
          raise e
        end
      end
    end

    log_error url, *request_errors.map(&:message) if request_errors.present? && result.nil?
    result
  end

  def get_html(url, options = {})
    resp = get_resp url, options
    Nokogiri::HTML resp if resp.present?
  end

  def get_json(url, options = {})
    resp = get_resp url, options
    JSON.parse resp if resp.present?
  end

  def get_image(url, options = {})
    response = get_resp url, { headers: image_headers }.merge(options)
    download_image url, response
  end

  def download_image(url, resp)
    uri_parts = uri_parts url
    filename = canonize_uri uri_parts[:path]&.split('/')&.last
    filename ||= 'image.png'
    file_ext = filename&.split('.')&.last || 'png'

    return if resp.blank? || resp.code >= 400

    @___temp_file = Tempfile.new
    @___temp_file.binmode
    @___temp_file.write resp.body
    # @___temp_file.flush

    content_type = resp.headers[:content_type] || "image/#{ file_ext }"
    headers = "Content-Disposition: form-data; name=\"[image]\"; "\
                "filename=\"#{ filename }\"\r\nContent-Type: #{ content_type }\r\n"

    downloaded_file = ActionDispatch::Http::UploadedFile.new tempfile: @___temp_file
    downloaded_file.instance_variable_set :@content_type, content_type
    downloaded_file.instance_variable_set :@original_filename, filename
    downloaded_file.instance_variable_set :@headers, headers
    downloaded_file
  end
end

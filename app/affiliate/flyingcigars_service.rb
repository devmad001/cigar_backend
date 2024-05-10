class FlyingcigarsService
  def initialize
    @woocommerce = WooCommerce::API.new(
      'https://flyingcigars.com',
      ENV['FLYING_CIGAR_CK'],
      ENV['FLYING_CIGAR_CS'],
      { wp_api: true, version: 'wc/v3' }
    )
    super
  end

  def products
    get_records'products'
  end

  def reviews
    get_records'products/reviews'
  end

  private

  def get_records(endpoint)
    response = @woocommerce.get(endpoint, { per_page: 100 })
    pages = response.headers['x-wp-totalpages']&.to_i

    return unless pages.is_a?(Integer)

    records = []
    pages.times do |i|
      records.concat @woocommerce.get(endpoint, { per_page: 100, page: i + 1 }).parsed_response
    end

    records
  end
end

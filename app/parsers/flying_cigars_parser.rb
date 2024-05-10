class FlyingCigarsParser
  VALID_CIGARS_NAMES = ['Cigars', 'Cigar Samplers', 'Cheap Cigars']
  VALID_CIGARS_OPTIONS = %w(Brand Profile Orgin Wrapper Binder FIller Shape)
  CIGARS_FILTERS = %w(Wrapper Shape Orgin)

  def initialize
    @products = FlyingcigarsService.new.products
    @reviews = FlyingcigarsService.new.reviews
    super
  end

  def save_new_products!
    @products.each { |p| save!(p.with_indifferent_access) }
  end

  private

  def save!(product)
    link =  product[:permalink]
    attributes = build_attributes(product)
    if attributes[:category_id] == 1 && attributes[:shapes].present?
      attributes[:shapes].each do |shape|
        attributes[:link] = link + "##{shape.gsub(' ', '')&.split('(').try(:first)}"
        product = Product.find_or_initialize_by(link: attributes[:link])
        attributes = attributes.except(:attachments_attributes, :reviews_attributes) unless product.new_record?
        if attributes[:shape_fltr].present?
          attributes[:shape_fltr] = shape
          attributes[:specifications][:shape] = shape
        end
        product.assign_attributes(attributes.except(:shapes))
        product.save!
      end
    else
      product = Product.find_or_initialize_by(link: attributes[:link])
      attributes = attributes.except(:attachments_attributes, :reviews_attributes) unless product.new_record?
      product.assign_attributes(attributes.except(:shapes))
      product.save!
    end
  end

  def category_name(category_name)
    return 'Cigars' if VALID_CIGARS_NAMES.include?(category_name)
    'Accessories'
  end

  def category_id(name)
    category = Category.find_by(original_title: name)
    return category.id if category.present?
    Category.create(title: name, original_title: name)&.id
  end

  def build_attributes(details)
    _attributes = {}
    _attributes[:category_id] = category_id(category_name(details[:categories].first[:name]))
    _attributes[:seller] = 'Flying Cigars'
    _attributes[:link] = details[:permalink]
    _attributes[:click_link] = details[:permalink] + '?ref=1'
    _attributes[:description] = Nokogiri::HTML(details[:description])&.text&.strip
    _attributes[:attachments_attributes] = details[:images].map do |img|
      { remote_attachment_url: img[:src] } if img[:src].present?
    end
    _attributes[:title] = details[:name]
    _attributes[:name] = details[:name]
    _attributes[:price] = details[:price]&.to_i * 100
    _attributes[:rating] = details[:average_rating]
    _attributes[:specifications] = build_specs(details)
    _attributes[:reviews_attributes] = build_reviews(details[:id])
    CIGARS_FILTERS.each do |filter|
      _attributes["#{filter.downcase}_fltr".to_sym] = _attributes[:specifications][filter.downcase.to_sym]
      if _attributes[:specifications][:orgin].present?
        _attributes[:country_fltr] = _attributes[:specifications][:orgin]
      end
    end
    _attributes[:shapes] = shapes(details)
    _attributes = _attributes.except(:orgin_fltr)
    _attributes
  end

  def build_specs(details)
    specs = {}
    specs[:stock] = details[:in_stock]
    details[:attributes].each do |i|
      if category_name(details[:categories].first[:name]) == 'Cigars'
        specs[i[:name]&.downcase&.to_sym] = i[:options]&.first if VALID_CIGARS_OPTIONS.include?(i[:name])
      else
        specs[i[:name]&.to_sym] = i[:options]&.first
      end
    end
    specs
  end

  def build_reviews(product_id)
    reviews = []
    @reviews.each do |review|
      if review['product_id'] == product_id
        r = {}
        r[:rating] = review['rating']
        r[:body] = Nokogiri::HTML(review['review'])&.text&.strip
        r[:reviewer_name] = review['reviewer']
        r[:review_date] = review['date_created']
        reviews << r
      end
    end
    reviews
  end

  def shapes(details)
    _shapes = details[:attributes].find { |obj| obj[:name] == 'Shape' }.try(:[], :options)
  end
end

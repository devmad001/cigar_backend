class AscendParser
  CATEGORIES = ['Cigars','Machine Made Cigars', 'Accessories']
  MAIN_FIELDS = %i(seller click_link description attachments_attributes reviews_attributes category_id rating)
  OPTION_FIELDS = %i(title price old_price discount link strength_fltr shape_fltr country_fltr wrapper_fltr)

  def initialize
    @attrs = {}
    @attributes = {}
    @data = AscendService.products
    return nil if @data.blank?
    @products = @data[:data]
    super
  end

  def save_new_products!
    list
    @products.each do |product|
      main_attributes = build_attributes(product)
      main_attributes[:category_id] = category_id(main_attributes[:category_name])
      @attributes = main_attributes
      if main_attributes[:seller] == 'CigarPage'
        if main_attributes[:category_name] != 'Accessories'
          details = Ascend::CigarPageDetails.product(main_attributes[:link])
          next if details.blank?
          @attributes = @attributes.merge(details)
        end
        save_or_update_products!(@attributes)
      elsif main_attributes[:seller] == 'Best Cigar Prices'
        if main_attributes[:category_name] != 'Accessories'
          details = Ascend::BestCigarDetails.product(main_attributes[:link])
          next if details.blank?
          @attributes = @attributes.merge(details)
        end
        save_or_update_products!(@attributes)
      end
      elsif main_attributes[:seller] == 'JRCigar.com'
        if main_attributes[:category_name] != 'Accessories'
          details = Ascend::JrCigarDetails.product(main_attributes[:link])
          next if details.blank?
          @attributes = @attributes.merge(details)
        end
        save_or_update_products!(@attributes)
      end
    end
  end

  def build_attributes(details)
    _attributes = {}
    _attributes[:seller] = details[:program_name]
    link = details[:buy_url].split('url=')
    _attributes[:link] = URI.unescape(link[1]).to_s || details[:buy_url]
    _attributes[:click_link] = details[:buy_url]
    _attributes[:description] = details[:description_long]
    _attributes[:attachments_attributes] = [{ remote_attachment_url: details[:image_url] }] if details[:image_url].present?
    _attributes[:title] = details[:name]
    _attributes[:price] = details[:price]&.gsub('.', '')&.to_i
    _attributes[:stock] = details[:in_stock]
    _attributes[:category_name] = category_name(details[:category_program])
    _attributes
  end

  private

  def pages
    @data[:meta][:pagination][:total_pages] if @data.present?
  end

  def new_products_page(page)
    data = AscendService.products(page)
    return [] if data.blank?
    data[:data]
  end

  def list
    pages.times do |page|
      @products.concat(new_products_page(page))
    end
  end

  def category_name(category_program)
    if category_program.present?
      name = category_program.split(' > ').last
      return 'Cigars' if name == 'Cigars'
      'Accessories'
    else
      'Cigars'
    end
  end

  def category_id(name)
    category = Category.find_by(original_title: name)
      return category.id if category.present?
      Category.create(title: name, original_title: name)&.id
  end

  def save_or_update_products!(attributes)
    attributes = attributes.except(:category_name)
    if attributes[:products].present?
      attributes[:products].each do |product|
        @attrs = attributes.slice(*MAIN_FIELDS).merge(product.slice(*OPTION_FIELDS))
        @attrs[:specifications] = product.except(*MAIN_FIELDS + OPTION_FIELDS)
      end
    else
      @attrs = attributes.slice(*MAIN_FIELDS).merge(attributes.slice(*OPTION_FIELDS))
      @attrs[:specifications] = attributes.except(*MAIN_FIELDS + OPTION_FIELDS)
    end
    save(attributes[:link])
  end

  def save(link)
    Product.find_or_initialize_by(link: link).tap do |p|
      @attrs = @attrs.except(:attachments_attributes, :reviews_attributes, :category_id, :specifications) unless p.new_record?
      p.assign_attributes(@attrs)
      p.save
    end
  end
end

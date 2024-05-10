class Parser < BaseParser
  class << self
    def store; end

    def resource
      @resource ||= Resource.find_by host: self.host
      @resource ||= Resource.create url: root, name: store
      @resource
    end

    def find_category(title, subcategory_id = nil)
      return if title.blank?
      category = Category.find_by original_title: title, category_id: subcategory_id
      category ||= Category.create title: title, original_title: title, category_id: subcategory_id
      category
    end

    def preload_images?
      false
    end

    def store_product!(info, category: nil)
      return if info.blank? || Product.find_by(link: info[:link]).present?

      _product = Product.new build_attributes info
      _product.category = category if category.present?
      _product.resource = resource

      unless _product.save
        log_error self.name,
                  __method__,
                  *_product.errors.full_messages,
                  info
      end
    rescue => e
      log_error self.name,
                __method__,
                e.message,
                info,
                category&.inspect
    end

    def store_products!
      each_products type: :new do |details, category|
        store_product! details, category: category
      end
    end

    def update_filters_fields
      # TODO: refactor and move to parsing details
      Product.where('country_fltr IS NULL OR strength_fltr IS NULL OR wrapper_fltr IS NULL OR shape_fltr IS NULL').find_each do |product|
        specs = product.specifications
        next unless specs.is_a?(Hash)
        fields = {}
        fields[:country_fltr] = CountryService.country specs['origin'] || specs['country']
        fields[:strength_fltr] = StrengthService.strength specs['strength']
        fields[:wrapper_fltr] = WrapperService.wrapper specs['wrapper_type'] || specs['wrapper'] || specs['wrapper_origin']
        fields[:shape_fltr] = ShapeService.shape specs['shape'] || specs['shapes']
        fields[:length_fltr] = specs['length']
        product.update(fields) if fields.present?
      end
    end

    def canonize_fltrs!(_attributes)
      [
        { key: :brand_name, service: BrandsService, method: :brand_name },
        { key: :country_fltr, service: CountryService, method: :country },
        { key: :strength_fltr, service: StrengthService, method: :strength },
        { key: :wrapper_fltr, service: WrapperService, method: :wrapper },
        { key: :shape_fltr, service: ShapeService, method: :shape }
      ].each do |i|
        _attributes[i[:key]] = i[:service].try i[:method], _attributes[i[:key]] if _attributes[i[:key]].present?
      end
    end

    def build_attributes(details, except: [])
      _details = recursive_compact_blank details
      return {} if !_details.is_a?(Hash) || _details.blank?

      _attributes = _details.slice *CANONICAL_FIELDS
      _attributes[:specifications] = _details.except *CANONICAL_FIELDS, *%i(images reviews)
      _attributes[:seller] = store

      _attributes[:reviews_attributes] = _details[:reviews] if _details[:reviews].present?

      if _details[:images].present?
        _attributes[:attachments_attributes] = _details[:images].map do |img|
          { remote_attachment_url: img }
        end

        _attributes[:attachments_attributes]
      end

      _attributes[:country_fltr] ||= [_details[:country], _details[:origin]].compact_blank.first
      _attributes[:wrapper_fltr] ||= _details[:wrapper]
      _attributes[:strength_fltr] ||= _details[:strength]
      _attributes[:shape_fltr] ||= _details[:shape]

      canonize_fltrs! _attributes
      recursive_compact_blank _attributes
    end

    def pagination(&block)
      list.each do |category|
        cat = find_category category[:name]

        self.instance_exec category[:links], cat, &block if block.is_a?(Proc)
      end
    end

    def each_products(type: :all, &block)
      pagination do |links, cat|
        filter_products_links(links, type: type, category: cat).each do |link|
          self.instance_exec product(link), cat, &block if block.is_a?(Proc)
        end
      end
    end

    def filter_products_links(links, type: :all, category: nil)
      return links if type == :all

      stored_products = Product.where(link: links)
      stored_products.update_all category_id: category&.id if category&.id.present?
      stored_products_links = stored_products.select(:link).pluck(:link)

      case type
      when :stored
        stored_products_links
      when :new
        links - stored_products_links
      else
        links
      end
    end
  end
end

class ProductUpdater
  PARSERS = [
    MonthClub,
    FamousSmoke,
    ThompsonCigar,
    GothamCigars,
    Cigars,
    Mikescigars,
    Jrcigars,
    Smokeinn,
    CigarsInternational,
    BnbTobacco
  ].freeze

  UPDATE_INTERVAL = 3.days

  class << self
    include LogHelper

    def parsers_map
      return @result if @result.present?

      @result = {}
      PARSERS.each { |p| @result[p.store] = p }
      @result
    end

    def update_product!(product)
      parser = parsers_map[product.resource&.name]

      return if parser.blank?

      root_link = product.link.split('#').first
      product_details = parser.product root_link

      case parser
      when BnbTobacco.name
        root_link_query = root_link + '%'
      when CigarsInternational.name
        product.link =~ /^\S+\/(\d+)\/?/
        root_link_query = $1.present? ? "%#{ $1 }/?" : nil
      end

      case parser.name
      when BnbTobacco.name, CigarsInternational.name
        if product_details.blank? && root_link_query
          Product
              .where('link SIMILAR TO ?', root_link_query)
              .where(resource: parser.resource)
              .update_all(status: :inactive, refreshed_at: DateTime.now)
          return
        end

        updated_products = []

        parser.store_product! product_details do |product_attributes|
          product_item = Product.find_by link: product_attributes[:link]
          updated_products << product_attributes[:link]

          if product_item.blank?
            product_item = Product.new product_attributes
            product_item.category = product.category
            product_item.resource = parser.resource
            product_item.save
          else
            ProductUpdater.save_product! product_item, product_attributes
          end
        end

        if root_link_query
          Product
              .where('link SIMILAR TO ?', root_link_query)
              .where(resource: parser.resource)
              .where.not(link: updated_products)
              .update_all(status: :inactive)
        end
      else
        if product_details.blank?
          product.update status: :inactive, refreshed_at: DateTime.now
          return
        end

        excepted_attributes = []

        if parser.preload_images? && product_details[:images].is_a?(Array) &&
            product_details[:images].count == product.attachments.count
          excepted_attributes << :attachments_attributes
        end

        hash_args = { except: excepted_attributes }.compact_blank
        product_attributes = parser.build_attributes product_details, **hash_args

        save_product! product, product_attributes
      end
    rescue => e
      log_error self.name,
                __method__,
                parser: parser&.name,
                product: product&.id,
                error: e.message
    end

    def update_all!(scope = nil)
      scope ||= all_products

      safe_exec do
        scope.find_each do |product|
          update_product! product if scope.exists?(id: product.id)
        end
      end
    end

    def all_products(interval: nil)
      Product
          .available_products
          .includes(:reviews, :attachments)
          .where(
            'refreshed_at IS NULL OR refreshed_at < :interval',
            interval: (interval || UPDATE_INTERVAL)&.ago
          )
          .order('random(products.id)')
    end

    def store_new!
      PARSERS.shuffle.each(&:store_products!)
    rescue => e
      log_error self.name, __method__, e.message
    end

    def safe_exec(&block)
      block&.yield
    rescue => e
      log_error self.name, __method__, e.message
    end

    def save_product!(product, attributes)
      resources_ids = {}

      %i(reviews attachments).each do |attr|
        attr_key = "#{ attr }_attributes".to_sym

        if attributes[attr_key].is_a?(Array) && attributes[attr_key].count != product.try(attr).count
          resources_ids[attr] = product.try(attr).ids
        else
          attributes.delete attr_key
        end
      end

      product.assign_attributes attributes
      product.refreshed_at = DateTime.now

      if product.changed? || resources_ids.present?
        product.save

        resources_ids.each do |attr, ids|
          product.try(attr).where(id: ids).destroy_all
        end

        true
      else
        false
      end
    end
  end
end

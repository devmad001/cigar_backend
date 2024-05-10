class ClickLinksSetter
  class << self
    include LogHelper

    def set_click_links!
      set_flexoffers!
      set_cj!
      Shareasale.set_all!
      ImpactLinksSetter.new.set_click_links!
    rescue => e
      log_error self.name, __method__, e.message
    end

    def set_cj!
      CjService::STORES.each do |host, pid|
        next unless pid.present?
        resource = Resource.find_by(host: host)
        next if resource.blank? || !resource.show?

        begin
          CjService.list(pid)
              &.dig('products', 'resultList')
              &.select { |link| link&.dig('linkCode', 'clickUrl') }
              &.each do |link|
            click_link = link&.dig('linkCode', 'clickUrl')

            if click_link && link['link']
              product = Product.find_by link: link['link'].split('#p-').first
              product.update_attribute :click_link, click_link if product.click_link.blank?
            end
          end
        rescue => e
          log_error self.name, __method__, e.message
        end
      end
    end

    def set_flexoffers!
      FlexoffersService::ADV_IDS.each do |host, aid|
        resource = Resource.find_by host: host

        next unless resource

        Product.where(resource: resource, click_link: nil).find_each do |product|
          deeplink = FlexoffersService.deeplink product.link, aid

          if deeplink.present?
            click_link = deeplink.find { |k, v| k.downcase == 'deeplink' }.last
            product.update_attribute :click_link, click_link if click_link.present?
          end
        end
      end
    end
  end
end

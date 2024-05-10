class CouponUpdater
  class << self
    include LogHelper

    def update_all!
      flexoffers!
      ascend_partner!
    end

    def ascend_partner!
      AscendService.coupons['data']&.each do |coupon_data|
        coupon_attributes = {
          # resource: get_host(FlexoffersService.host_by_id(coupon_data['advertiserId'])),
          coupon_id: coupon_data['id'],
          name: coupon_data['name'],
          description: coupon_data['description'],
          code: coupon_data['code'],
          start_date: coupon_data['start_date'],
          end_date: coupon_data['end_date'],
          percentage_off: coupon_data['percentageOff'],
          dollar_off: coupon_data['dollarOff'],
          exclusive: coupon_data['exclusive'] == 'yes',
          status: coupon_data['status'],
          response: coupon_data
        }

        coupon = Coupon.find_by coupon_id: coupon_attributes[:coupon_id]
        coupon ||= Coupon.new
        coupon.assign_attributes coupon_attributes


        log_error coupon.errors.full_messages unless coupon.save
      end
    rescue => e
      log_error self.name, __method__, e.message
    end

    def flexoffers!
      FlexoffersService.coupons['results']&.each do |coupon_data|
        coupon_attributes = {
          resource: get_host(FlexoffersService.host_by_id(coupon_data['advertiserId'])),
          coupon_id: coupon_data['linkId'],
          name: coupon_data['linkName'],
          description: coupon_data['linkDescription'],
          code: coupon_data['couponCode'],
          start_date: coupon_data['startDate'],
          end_date: coupon_data['endDate'],
          percentage_off: coupon_data['percentageOff'],
          dollar_off: coupon_data['dollarOff'],
          response: coupon_data
        }

        coupon = Coupon.find_by coupon_id: coupon_attributes[:coupon_id]
        coupon ||= Coupon.new
        coupon.assign_attributes coupon_attributes


        log_error coupon.errors.full_messages unless coupon.save
      end
    rescue => e
      log_error self.name, __method__, e.message
    end

    def all_hosts
      @hosts ||= Resource.all.to_a
    end

    def get_host(host)
      all_hosts.find { |h| h.host == host }
    end
  end
end

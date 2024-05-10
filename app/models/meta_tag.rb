# == Schema Information
#
# Table name: meta_tags
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  page_type   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class MetaTag < ApplicationRecord
  enum page_type: %i(main_page profile search_page wishlist orderhistory privacy terms help blog article advertise)
end

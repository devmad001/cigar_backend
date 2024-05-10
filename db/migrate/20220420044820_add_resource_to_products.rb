class AddResourceToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :resource

    Resource.all.each do |resource|
      Product.where("link ILIKE '%#{ resource.host }%'").update_all resource_id: resource.id
    end
  end
end

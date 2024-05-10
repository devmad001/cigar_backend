ActiveAdmin.register Product do
  actions :all, except: %i(new create)
  permit_params :category_id, :status
  includes :category, :attachments, :actions, :resource, :reviews

  %i(title name category resource created_at refreshed_at).each do |column|
    filter column
  end

  scope :active, default: true do |scoped_collection|
    scoped_collection.
        available_products
        .select(
          "*",
          '(SELECT count(id) FROM actions WHERE actions.entity_id = products.id AND '\
            "actions.entity_type = 'Product' AND actions.action_type = "\
            "#{ Action.action_types[:view_product] }) AS views_count",
          '(SELECT count(id) FROM actions WHERE actions.entity_id = products.id AND '\
            "actions.entity_type = 'Product' AND actions.action_type = "\
            "#{ Action.action_types[:move_to_seller] }) AS go_to_seller_count"
        )
  end

  scope :inactive do |scoped_collection|
    scoped_collection.inactive
  end

  scope :category_blank do |scoped_collection|
    scoped_collection.where(category_id: nil)
  end

  index do
    selectable_column

    column :image do |product|
      image_tag product.attachments.first.attachment.thumbnail.url, height: 30 if product.attachments.present?
    end

    column :views_count, sortable: :views_count
    column :go_to_seller_count, sortable: :go_to_seller_count

    %i(title link category created_at refreshed_at).each do |column_name|
      column column_name
    end

    actions
  end

  form do |f|
    f.semantic_errors :base
    f.inputs do
      f.input :category
      f.input :status
    end
    f.actions
  end

  show do |product|
    attributes_table do
      %w(title name description).each do |column|
        row column if product[column].present?
      end

      %w(price discount).each do |column|
        row(column) { monetize product[column] } if product[column].present?
      end

      row :old_price do
        monetize product[:old_price]
      end if product[:old_price].present? && !product[:old_price].zero?

      row :resource

      %w(link click_link).each do |column|
        row column do
          a product[column], href: product[column], target: '_blank'
        end if product[column].present?
      end

      row 'view on site' do
        site_link = product.site_link
        a site_link, href: site_link, target: '_blank'
      end

      %w(rating brand_name).each do |column|
        row column if product[column].present?
      end

      row :status do
        status_tag product.status
      end

      row :category if product.category_id.present?
      list_row :specifications if product.specifications.present?

      %i(created_at updated_at refreshed_at).each do |column|
        row column
      end

      row :images do
        div style: 'text-align: center' do
          product.attachments.map do |a|
            image_tag a.attachment.url, height: 350
          end.join().html_safe
        end
      end if product.attachments.present?
    end

    unless product.reviews.count.zero?
      h3 'Reviews'

      table_for product.reviews, { sortable: true, class: 'index_table index' } do
        column :reviewer_name
        column :rating
        column :title
        column :body
        column :review_date
      end
    end
  end
end

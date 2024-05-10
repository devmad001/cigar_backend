ActiveAdmin.register Category do
  permit_params :title, :description, :category_id, :image, :position, :show
  includes :category, :actions
  reorderable

  controller do
    def scoped_collection
      Category.select(
        '*',
        '(SELECT count(id) FROM actions WHERE actions.entity_id = categories.id AND '\
          "actions.entity_type = 'Category') AS activities_count"
      )
    end
  end


  index as: :reorderable_table do
    selectable_column
    column :title
    column :activities_count, sortable: :activities_count

    column :image do |category|
      image_tag category.image.thumbnail.url, height: 30 if category.image.present?
    end

    column :active_products do |category|
      category.products.available_products.count
    end

    column :inactive_products do |category|
      category.products.inactive.count
    end

    column :created_at
    column :updated_at
    toggle_bool_column :show
    actions
  end

  %i(title description category created_at updated_at).each do |column|
    filter column
  end

  form do |f|
    f.semantic_errors :base
    f.inputs do
      f.input :image, as: :file,
              hint: image_tag(f.object.image.present? ? f.object.image.url : '', height: 250),
              input_html: { class: 'image-input', accept: 'image/*' }
      f.input :title
      f.input :category
      f.input :description, as: :ckeditor
      f.input :position
      f.input :show
    end
    f.actions
  end

  show do |category|
    attributes_table do
      row :image do
        image_tag category.image.url, height: 250
      end if category.image.present?

      row :category do
        link_to category.category.title, admin_category_path(category.category)
      end if category.category.present?

      row :title

      row :description do
        simple_format category.description
      end

      bool_row :show

      row :active_products do
        resource.products.available_products.count
      end

      row :inactive_products do
        resource.products.inactive.count
      end

      row :created_at
      row :updated_at
    end
  end
end

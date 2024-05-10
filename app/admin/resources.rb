ActiveAdmin.register Resource do
  permit_params :name, :url, :show

  index do
    selectable_column
    column :name
    column :url

    column :active_products do |resource|
      resource.products.available_products.count
    end

    column :inactive_products do |resource|
      resource.products.inactive.count
    end

    column :created_at
    column :updated_at
    toggle_bool_column :show
    actions
  end

  %i(name url show created_at updated_at).each do |column|
    filter column
  end

  form do |f|
    f.semantic_errors :base
    f.inputs do
      f.input :name
      f.input :url
      f.input :show
    end
    f.actions
  end

  show do |resource|
    attributes_table do
      row :name
      row :url
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

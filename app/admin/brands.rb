ActiveAdmin.register Brand do
  permit_params :name, :image, :active

  index do
    selectable_column

    column :image do |brand|
      image_tag brand.image.thumbnail.url, height: 30 if brand.image.present?
    end

    %i(name active created_at updated_at).each do |column_name|
      column column_name
    end

    actions
  end

  filter :name
  filter :active
  filter :created_at
  filter :updated_at

  form(html: { multipart: true }) do |f|
    brands_names = Brand.available_names
    brands_names << resource.name unless resource.new_record?

    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name, as: :select, collection: brands_names.compact.uniq
      f.input :image, as: :file,
              hint: image_tag(f.object.image.present? ? f.object.image.url : '', height: 250),
              input_html: { class: 'image-input', accept: 'image/*' }
      f.input :active
    end
    f.actions
  end

  show do |brand|
    attributes_table do
      row :name

      row :image do
        image_tag brand.image.url, size: '300'
      end if brand.image.present?

      bool_row :active
      row :created_at
      row :updated_at
    end
  end
end

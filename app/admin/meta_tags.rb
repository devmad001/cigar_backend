ActiveAdmin.register MetaTag do
  permit_params :title, :description, :page_type

  %i(title description created_at updated_at).each do |column|
    filter column
  end

  filter :page_type, as: :select, collection: MetaTag.page_types.map { |k, v| [k.to_s.humanize, v] }

  index do
    selectable_column

    column :title
    column :description

    column :page_type do |meta_tag|
      status_tag meta_tag.page_type
    end

    column :created_at
    column :updated_at

    actions
  end

  show do |meta_tag|
    attributes_table do
      row :title
      row :description

      row :page_type do
        status_tag meta_tag.page_type
      end

      row :created_at
      row :updated_at
    end
  end
end

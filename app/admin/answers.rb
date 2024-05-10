ActiveAdmin.register Answer do
  menu :label => 'FAQ Page'
  permit_params :title, :body

  index do
    selectable_column
    column :title
    column :body do |answer|
      simple_format answer.body
    end
    column :created_at
    column :updated_at
    actions
  end

  %i(title body created_at updated_at).each do |column|
    filter column
  end

  form do |f|
    f.semantic_errors :base
    f.inputs do
      f.input :title
      f.input :body, as: :ckeditor
    end
    f.actions
  end

  show do |answer|
    attributes_table do
      row :title
      row :body do
        simple_format answer.body
      end
      row :created_at
      row :updated_at
    end
  end
end

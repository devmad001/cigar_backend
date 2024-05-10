ActiveAdmin.register AdBanner do
  permit_params :title, :body, :ad_type
  filter :title

  index do
    selectable_column
    column :title
    column :body
    column :ad_type
    column :created_at
    actions
  end
end

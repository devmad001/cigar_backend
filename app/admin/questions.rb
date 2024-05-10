ActiveAdmin.register Question do
  actions :index, :show, :destroy

  index do
    selectable_column
    column :full_name
    column :email
    column :body
    column :created_at
    actions
  end

  %i(full_name email body created_at).each do |column|
    filter column
  end

  show do |question|
    attributes_table do
      row :full_name
      row :email
      row :body
      row :created_at
    end
  end
end

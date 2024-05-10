ActiveAdmin.register User do
  actions :all, except: %i(new create update edit)

  index do
    selectable_column
    column :image do |user|
      image_tag user.image.thumbnail.url, height: 30 if user.image.present?
    end

    %i(
      email
      full_name
      phone_number
      created_at
      updated_at
    ).each do |column_name|
      column column_name
    end

    actions
  end

  %i(
    full_name
    email
    phone_number
    state
    city
    address
    created_at
    updated_at
  ).each do |column|
    filter column
  end

  show do |user|
    attributes_table do
      row :image do
        image_tag user.image.url, height: 250
      end if user.image.present?

      %i(
        email
        full_name
        phone_number
        state
        city
        address
        created_at
        updated_at
      ).each do |column_name|
        row column_name
      end
    end
  end
end

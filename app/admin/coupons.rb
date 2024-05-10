ActiveAdmin.register Coupon do
  permit_params :name, :description, :code, :resource_id, :start_date,
                :end_date, :exclusive, :percentage_off, :dollar_off

  index do
    selectable_column
    column :name

    %w(code status).each do |key|
      column key.to_sym do |coupon|
        if coupon[key] =~ /^https?:\/\/.+/
          coupon[key]
        else
          status_tag coupon[key]
        end if coupon[key].present?
      end
    end

    column :resource
    column :start_date
    column :end_date
    column :updated_at
    actions
  end

  %i(name description start_date end_date created_at updated_at).each do |column|
    filter column
  end

  form do |f|
    f.semantic_errors :base
    f.inputs do
      f.input :name
      f.input :description
      f.input :code
      f.input :resource
      f.input :start_date, as: :date_time_picker
      f.input :end_date, as: :date_time_picker
      f.input :percentage_off
      f.input :dollar_off
      f.input :exclusive
    end
    f.actions
  end

  show do |coupon|
    attributes_table do
      row :name

      row :code do
        if coupon.code =~ /^https?:\/\/.+/
          coupon.code
        else
          status_tag coupon.code
        end
      end if coupon.code.present?

      %w(percentage_off dollar_off).each do |key|
        row key.to_sym if coupon[key].present? && !coupon[key].zero?
      end

      %w(status coupon_type).each do |key|
        status_tag coupon[key] if coupon[key].present?
      end

      row :resource
      row :description
      row :start_date
      row :end_date if coupon.end_date.present?
      bool_row :exclusive unless coupon.exclusive.nil?
      row :created_at
      row :updated_at
    end
  end
end

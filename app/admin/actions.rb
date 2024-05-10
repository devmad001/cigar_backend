ActiveAdmin.register Action do
  permit_params :q, :guest_id_eq
  actions :all, except: %i(new create edit update)
  includes :entity, guest: :user

  filter :guest, as: :select

  filter :action_type,
         as: :select,
         collection: ->{ Action.action_types.map {|k,v| [k.humanize, v]} }

  filter :entity_type, as: :select

  filter :entity_of_Category_type_id,
         label: 'Category Entity',
         as: :select,
         collection: ->{ Category.all.map{ |c| [c.title, c.id] } }

  scope :all, default: true do |scoped_collection|
    sc = scoped_collection

    if (entity_id = params.dig(:q, :entity_of_Category_type_id_eq)).present?
      sc = sc.where(entity_id: entity_id)
    end

    if (guest_id_eq = params.dig(:q, :guest_id_eq)).present?
      sc = sc.where(guest_id: guest_id_eq)
    end

    sc
  end

  index do
    selectable_column
    column :action_type do |action|
      status_tag action.action_type&.humanize
    end
    column :guest
    column :entity_type
    column :entity
    column :description
    column :created_at
    actions
  end

  show do |action|
    attributes_table do
      row :action_type do
        status_tag action.action_type&.humanize
      end if action.action_type.present?

      row :guest
      row :entity_type
      row :entity
      row :description
      row :created_at
    end

    # TODO: add table with most popular categories or products
  end
end

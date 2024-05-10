ActiveAdmin.register Article do
  permit_params :title, :body, :image, :article_type,
                attachments_attributes: %i(id attachment position _destroy)

  scope :blog, default: true
  scope :news

  controller do
    include ActiveAdminHelper
    helper 'active_admin' # for views
  end

  index do
    selectable_column

    column :image do |article|
      image_tag article.image.thumbnail.url, height: 30 if article.image.present?
    end

    column :title
    column :created_at
    column :updated_at
    actions
  end

  filter :title
  filter :created_at
  filter :updated_at

  form(html: { multipart: true }) do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title, input_html: chirilic_regexp
      f.input :article_type
      f.input :image, as: :file,
              hint: image_tag(f.object.image.present? ? f.object.image.url : '', height: 250),
              input_html: { class: 'image-input', accept: 'image/*' }
      f.input :body

      div do
        div style: 'padding-left: 20.5%' do
          Article::INSTRUCTION.html_safe
        end
      end

      f.inputs do
        f.has_many :attachments, allow_destroy: true do |a|
          a.input :id, as: :hidden unless a.object.new_record?
          a.input :position

          preview = nil
          if a.object.attachment.present? && a.object.image?
            preview = "<img height=250 src=\"#{ a.object.attachment.url }\" >"
          else
            preview = "<video controls height=250 src=\"#{ a.object.attachment.url }\" >"
          end

          a.input :attachment, as: :file,
                  hint: preview&.html_safe,
                  input_html: { class: 'image-input', accept: 'image/*, video/*' }
        end
      end
    end
    f.actions
  end

  show do |article|
    attributes_table do
      row :title

      row :attachment do
        image_tag article.image.url, size: '300' if article.image.present?
      end

      row :body do
        article.compile_body.html_safe
      end

      row :article_type do
        status_tag article.article_type
      end

      row :created_at
      row :updated_at
    end
  end
end

class Api::V1::MetaTagsController < Api::V1::BaseController
  skip_before_action :authenticate

  def get_meta
    @meta = MetaTag.find_by page_type: permited_parameter[:page_type]
    return render_error I18n.t('errors.not_found'), :not_found if @meta.blank?
    render json: { meta: @meta }
  end
end

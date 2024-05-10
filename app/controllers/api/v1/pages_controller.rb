class Api::V1::PagesController < Api::V1::BaseController
  skip_before_action :authenticate
  before_action :init

  def show
  end

  def html_page
    @title = @page.title
    @content = @page.content
    render layout: false, formats: %i(html)
  end

  private

  def init
    page_type = permited_parameter[:id]&.to_s&.underscore
    if Page.page_types.keys.include?(page_type)
      @page = Page.find_by! page_type: page_type
    else
      render_errors I18n.t('errors.page_not_found'), :not_found
    end
  end
end

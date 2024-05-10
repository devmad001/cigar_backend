class Api::BaseController < ActionController::API
  before_action :set_default_format, :set_locale, :authenticate

  rescue_from ActiveRecord::RecordNotFound, with: :not_found_record

  include ApplicationHelper
  include SessionsHelper
  include BooleanHelper

  protected

  def authenticate
    if current_user.present?
      current_session.update_lifetime!
    else
      render_errors I18n.t('errors.access_denied'), :unauthorized
    end
  end

  def set_default_format
    request.format = :json
  end

  def set_locale
    locale = request.headers['locale']&.to_sym
    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
  end

  def render_message(message)
    render json: { message: message }
  end

  def render_ok
    render_message I18n.t('messages.ok')
  end

  def render_errors(errors, status = :unprocessable_entity)
    render json: { errors: (errors.is_a?(Array) ? errors : [errors]) }, status: status
  end

  def render_error(error, status = :unprocessable_entity)
    render json: { error: error }, status: status
  end

  def not_found_record(exception)
    render_errors "#{ exception.model } #{ I18n.t('errors.not_found') }", :not_found
  end

  def pagination_params
    @page = params[:page].to_i
    @page = 1 if @page < 1
    @per_page = params[:per_page].to_i
    @per_page = 10 if @per_page < 1
    @per_page = 50 if @per_page > 50
    @offset = (@page - 1) * @per_page
  end

  def save_record(record, render: nil, status: :ok)
    if record.save
      if render.present?
        render render, status: status
      else
        render_ok
      end
    else
      render_errors record.errors.full_messages
    end
  end

  def check_result(record, action, *_args, render: nil, status: :ok)
    if record.try action, *_args
      if render.present?
        render render, status: status
      else
        render_ok
      end
    else
      render_errors record.errors.full_messages
    end
  end

  def permited_parameter
    @permited_parameter ||= proc { |key| params.permit(key).try(:[], key) }
  end

  def list(model, query_class, action, *_args)
    pagination_params

    @variable ||= "@#{ model.name.underscore.pluralize.split("/").last }"

    query = query_class
                .try(action, params, *_args)
                .take(@per_page)
                .skip(@offset)

    *_args.last[:count] = true if _args.last.is_a?(Hash)

    count_query = query_class.try(action, params, *_args)
    self.instance_variable_set @variable, model.find_by_sql(query.to_sql)
    @count = model.find_by_sql(count_query.to_sql).count
  end
end

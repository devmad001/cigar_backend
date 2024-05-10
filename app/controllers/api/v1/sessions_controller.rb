class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate, only: %i(create social_login)
  before_action :set_social_data, only: :social_login

  def create
    if permited_parameter[:email].blank?
      render_errors "Email #{ I18n.t('errors.blank')} "
      return
    end

    @user = User.find_by email: permited_parameter[:email]

    if @user&.authenticate?(params[:password])
      sign_in @user
      render json: { session_token: current_session&.id, current_user: current_user.info }
    else
      render_errors I18n.t('errors.wrong_email_or_password'), :unauthorized
    end
  end

  def social_login
    @user = User.find_by(
      '(social_type = :social_type AND social_id = :social_id) OR email = :email',
      social_type: User.social_types[params[:social_type]],
      social_id: @social_user_params[:social_id]&.to_s,
      email: @social_user_params[:email]
    )

    if @user.blank?
      @user = User.new @social_user_params
    else
      params = @social_user_params
      params = params.except(:remote_image_url) if @user.self_update?
      @user.assign_attributes params
    end

    if @user.save
      sign_in @user
      render json: { session_token: current_session&.id, current_user: current_user.info }
    else
      render_errors @user.errors.full_messages
    end
  end

  def destroy
    sign_out
    render_ok
  end

  private

  def set_social_data
    case params[:social_type]&.to_sym
    when :google
      google_login
    when :facebook
      facebook_login
    else
      render_errors "#{ I18n.t('errors.wrong_social_type') } #{ params[:social_type] }"
    end
  end

  def google_login
    api_path = URI "https://www.googleapis.com/oauth2/v3/userinfo?access_token=#{ params[:access_token] }"
    response = ::Net::HTTP.get_response(api_path)

    begin
      data = JSON.parse response.body, symbolize_names: true
    rescue => e
      return render_errors e.message
    end

    case response.code.to_i
    when 200
      @social_user_params = {
        social_id: data[:sub],
        full_name: data[:name],
        email: data[:email],
        social_type: :google
      }
      @social_user_params.merge!(remote_image_url: data[:picture]) if data[:picture].present?
    when 400
      render_errors I18n.t('errors.invalid_token')
    else
      render_errors "#{ data[:error] } #{ data[:error_description] }"
    end
  end

  def facebook_login
    query = {
      access_token: params[:access_token],
      fields: 'id,name,email,picture.width(500).height(500)',
      format: 'json',
      scope: 'email'
    }

    api_path = URI "https://graph.facebook.com/v3.0/me?#{ query.to_query }"
    response = ::Net::HTTP.get_response(api_path)

    begin
      data = JSON.parse response.body, symbolize_names: true
    rescue => e
      return render_errors e.message
    end

    case response.code.to_i
    when 200
      @social_user_params = {
        social_id: data[:id],
        social_type: :facebook,
        email: data[:email],
        full_name: data[:name],
      }

      if data.dig(:picture, :data, :url).present?
        @social_user_params.merge!(remote_image_url: data.dig(:picture, :data, :url))
      end
    when 400
      render_errors I18n.t('errors.invalid_token')
    else
      render_errors I18n.t('errors.login_error')
    end
  end
end

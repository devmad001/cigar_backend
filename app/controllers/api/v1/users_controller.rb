class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :authenticate, only: %i(create forgot_password reset_password newsletter)
  before_action :init, only: %i(show forgot_password)

  def profile
    render json: { current_user: current_user.info }
  end

  def update
    filtered_params = profile_params
    if current_user.social? && (params[:remove_image].present? || params[:image].present?)
      filtered_params[:self_update] = true
    end

    current_user.assign_attributes filtered_params
    if current_user.save
      profile
    else
      render_errors current_user.errors.full_messages
    end
  end

  def create
    @user = User.new create_params
    if @user.save
      sign_in @user
      render json: { session_token: current_session&.id, current_user: current_user.info }
    else
      render_errors @user.errors.full_messages
    end
  end

  def forgot_password
    @user.forgot_password
    render_ok
  end

  def reset_password
    user = User.find_by! token: permited_parameter[:token]
    user.reset_password! permited_parameter[:password],
                         permited_parameter[:password_confirmation]

    return render_errors user.errors.full_messages if user.errors.present?
    render_ok
  end

  def change_password
    current_user.change_password! permited_parameter[:current_password],
                                  permited_parameter[:password],
                                  permited_parameter[:password_confirmation]
    check_result
  end

  def change_email
    current_user.change_email!(
      permited_parameter[:password],
      permited_parameter[:email]
    )
    check_result
  end

  def change_phone_number
    current_user.change_phone_number! permited_parameter[:password],
                                      permited_parameter[:phone_number],
                                      permited_parameter[:code]
    check_result
  end

  def destroy
    current_user.destroy
    render_ok
  end

  def newsletter
    if current_user.present?
      current_user.newsletter!
      save_record NewsletterSubscriber.new(email: current_user.email)
    else
      save_record NewsletterSubscriber.new(params.permit :email)
    end
  end

  private

  alias_method :check_result_base, :check_result

  def check_result
    if current_user.errors.blank?
      render_ok
    else
      render_errors current_user.errors.full_messages
    end
  end

  def init
    status = :not_found
    if %w(forgot_password).include? params[:action]
      if permited_parameter[:email].blank?
        return render_errors "Email #{ I18n.t('errors.blank') }"
      end

      @user ||= User.find_by email: permited_parameter[:email]
      status = :unauthorized
      error_message = I18n.t('errors.wrong_email')
    else
      @user ||= User.find_by id: params[:id]
      error_message = I18n.t('errors.user_not_found')
    end
    render_errors error_message, status if @user.blank?
  end

  def create_params
    params.permit :email,
                  :phone_number,
                  :password,
                  :password_confirmation,
                  :full_name,
                  :state,
                  :city,
                  :address
  end

  def profile_params
    params.permit :full_name,
                  :image,
                  :remove_image,
                  :email,
                  :phone_number,
                  :full_name,
                  :state,
                  :city,
                  :address,
                  :self_update
  end
end

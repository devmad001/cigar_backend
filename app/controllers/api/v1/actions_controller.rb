class Api::V1::ActionsController < Api::V1::BaseController
  before_action :init_guest
  skip_before_action :authenticate

  def create
    action = @guest.actions.build action_params
    save_record action
  end

  private

  def init_guest
    if (@guest ||= find_guest).present?
      @guest
    else
      _guest_params = guest_params
      _guest_params.delete! :user_id if auth_user.blank?
      @guest = Guest.create _guest_params
    end
  end

  def find_guest
    if auth_user.present?
      Guest.find_by user_id: auth_user.id
    else
      Guest.find_by ip: permited_parameter[:ip]
    end
  end

  def auth_user
    @user ||= User.find_by id: permited_parameter[:user_id]
  end

  def action_params
    params.permit :action_type, :entity_type, :entity_id
  end

  def guest_params
    params.permit :ip, :location, :user_id
  end
end

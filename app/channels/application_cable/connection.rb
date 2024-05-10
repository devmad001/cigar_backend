module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      reject_unauthorized_connection if current_user.blank?
    end

    def session_token
      @session_token ||= [cookies[:session_token], request.params[:session_token]].compact.first
    end

    def current_session
      @current_session ||= Session.find_by token: session_token
    end

    def current_user
      @current_user ||= current_session&.user
    end

    def current_user_id
      current_user&.id
    end

    def get_cookie(key)
      cookies[key]
    end
  end
end

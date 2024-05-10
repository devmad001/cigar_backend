module ApplicationCable
  class Channel < ActionCable::Channel::Base
    private

    def current_user
      @current_user ||= connection.current_user
    end

    def reply(data)
      ActionCable.server.broadcast channel_id, data
    end
  end
end

# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # reject_unauthorized_connection unless verify_connection
    end

    protected

    def verify_connection
      request.key?('HTTP_USER_KEY') && User.find_by(key: request.headers['HTTP_USER_KEY'])
    end
  end
end

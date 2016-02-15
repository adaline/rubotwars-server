# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      if request.key? 'HTTP_USER_KEY'
        User.find_by(key: request.headers['HTTP_USER_KEY'])
      else
        reject_unauthorized_connection
      end
    end
  end
end

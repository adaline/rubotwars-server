# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :bot

    def connect
      reject_unauthorized_connection unless @bot = verify_connection
    end

    protected

    def verify_connection
      if request.key?('HTTP_USER_KEY') && request.key?('HTTP_USER_NAME')
        Bot.new(request.headers['HTTP_USER_NAME'], request.headers['HTTP_USER_KEY'])
      else
        false
      end
    end
  end
end

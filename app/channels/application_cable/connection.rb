# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :bot

    def connect
      if request.key?('HTTP_USER_KEY') && request.key?('HTTP_USER_NAME')
        if Match.active?
          reject_unauthorized_connection
        else
          @bot = Bot.new(request.headers['HTTP_USER_NAME'], request.headers['HTTP_USER_KEY'])
          @bot.save
        end
      end
    end
  end
end

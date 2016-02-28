class MatchChannel < ApplicationCable::Channel
  def subscribed
    stream_for bot
  end

  def unsubscribed
  end

  def scan
    log 'Scanning'
    bot.add_move(action: :scan)
    MatchChannel.broadcast_to(bot, 'action' => 'response', 'result' => ['empty', 'enemy', 'wall'].sample)
  end

  def turn(data)
    log 'Turning'
    p data
    MatchChannel.broadcast_to(bot, 'action' => 'response', 'result' => true)
  end

  def move_forward
    log 'Moving'
    MatchChannel.broadcast_to(bot, 'action' => 'response', 'result' => true)
  end

  def fire
    log 'Firing'
    MatchChannel.broadcast_to(bot, 'action' => 'response', 'result' => true)
  end

  private

  def bot
    Rails.cache.fetch("rubot/#{bot.key}", expires_in: 1.hour) do
      Bot.new(bot.name, bot.key)
    end
  end

  def log(info)
    Rails.logger.debug "#{bot.name}: #{info}"
  end
end

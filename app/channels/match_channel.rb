class MatchChannel < ApplicationCable::Channel
  def subscribed
    stream_for bot
    Seek.create(bot)
  end

  def unsubscribed
    Seek.remove(bot)
  end

  def scan
    log 'Scanning'
    local_bot = fresh_bot
    local_bot.result = match.scan(local_bot)
    local_bot.save
  end

  def turn(data)
    log 'Turning'
    match.turn(fresh_bot, data['direction'].to_sym)
  end

  def move_forward
    log 'Moving'
    match.move_forward(fresh_bot)
  end

  def fire
    log 'Firing'
    match.fire(fresh_bot)
  end

  def acknowledge
    local_bot = fresh_bot
    local_bot.sent = false
    local_bot.result = nil
    local_bot.acknowledged = true
    local_bot.save
    last_move_index = REDIS.get('rubot_last_move').to_i
    next_move_by = (last_move_index == 1) ? 0 : 1
    REDIS.set('rubot_last_move', next_move_by)
  end

  private

  def fresh_bot
    Bot.load(bot.key)
  end

  def match
    Match.load
  end

  def log(info)
    Rails.logger.debug "#{bot.name}: #{info}"
  end
end

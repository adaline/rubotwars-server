class MatchChannel < ApplicationCable::Channel
  def subscribed
    stream_for bot
    Seek.create(bot)
  end

  def unsubscribed
    Seek.remove(bot)
    Match.remove
  end

  def scan
    log 'Got scan'
    local_bot = fresh_bot
    local_bot.result = match.scan(local_bot)
    local_bot.save
  end

  def turn(data)
    log 'Got turn'
    match.turn(fresh_bot, data['direction'].to_sym)
  end

  def move_forward
    log 'Got move_forward'
    match.move_forward(fresh_bot)
  end

  def fire
    log 'Got fire'
    match.fire(fresh_bot)
  end

  def acknowledge(data)
    acknowledge_key = data['acknowledge_key']
    if REDIS.sismember('rubot_acknowledge_keys', acknowledge_key)
      REDIS.srem('rubot_acknowledge_keys', acknowledge_key)
    end
  end

  private

  def fresh_bot
    Bot.load(bot.key)
  end

  def match
    Match.load
  end

  def log(info)
    Rails.logger.debug "#{bot.key}: #{info}"
  end
end

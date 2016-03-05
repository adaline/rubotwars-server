class MasterChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'master:all'
  end
  def unsubscribed
  end

  def self.start(bots, map)
    broadcast_to 'all', { status: 'start', bots: bots, map: map }
  end

  def self.update(bots, map)
    broadcast_to 'all', { status: 'update', bots: bots, map: map }
  end

  def self.turn(bot, direction)
    broadcast_to 'all', { status: 'turn', bot: bot, direction: direction }
  end

  def self.scan(bot)
    broadcast_to 'all', { status: 'scan', bot: bot }
  end

  def self.fire(bot)
    broadcast_to 'all', { status: 'fire', bot: bot }
  end


  def self.game_over(bot)
    broadcast_to 'all', { status: 'game_over', winner: bot }
  end
end

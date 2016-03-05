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

  def self.game_over()
    broadcast_to 'all', { status: 'game_over' }
  end
end

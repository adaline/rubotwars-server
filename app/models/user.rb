class User < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :key

  before_validation :generate_key

  def appear
    update_attributes(online: true)
    reload
  end

  def disappear
    update_attributes(online: false)
    reload
  end

  def request_move
    Timeout::timeout(5) do
      MatchChannel.broadcast_to(self, 'action' => 'urmove')
      loop do
        reload
        break if next_move?
        sleep 0.2
      end
      next_move
    end
  end

  def move_ready(data)
    update_attributes(next_move: data)
  end

  private

  def generate_key
    self.key ||= SecureRandom.hex(10)
  end
end

class Bot
  attr_reader :name, :key
  
  def initialize(name, key)
    @name = name
    @key = key
    @x = 0
    @y = 0
    @lives = 3
    @moves = []
  end

  def start
    MatchChannel.broadcast_to(self, 'action' => 'start')
  end

  def next_move
    loop do
      break if @moves.any?
      sleep 0.2
    end
    @moves.pop
  end

  def add_move(data)
    @moves << data
  end

  def dead?
    @lives == 0
  end
end

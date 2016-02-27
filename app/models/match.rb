class Match
  def initialize
    @map = [
      [1,0,0,0,9,0,0,0],
      [0,0,0,9,0,0,0,0],
      [0,0,0,0,0,0,0,0],
      [0,0,9,9,9,9,0,0],
      [0,0,0,0,0,0,0,0],
      [0,0,0,9,9,0,0,0],
      [0,0,0,0,0,0,0,0],
      [0,9,0,0,0,0,0,1]
    ]
    @players = []
  end

  def add_player(bot)
    @players << bot
    start if @players.count == 2
  end

  def perform_move(player)
  end

  def start
    loop do
      @players.each do |player|
        break if player.dead?
        perform_move player
      end
    end
  end
end

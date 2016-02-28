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
  end

  def scan(player)
    # Figure out which way the player is facing
    # Return what is in front of the player
    case player.direction
    when :left
      if player.x == 0
        return :wall
      else
        front_tile = map[player.y][player.x - 1]
        if front_tile == 0
          op = other_player(player)
          if op.x == player.x - 1 && op.y = op.y
            return :enemy
          else
            return :empty
          end
        elsif front_tile == 9
          return :wall
        end
      end
    when :right
    when :up
    when :down
    end
  end

  def fire(player)
    # Figure out what is in front of the player
    # If its another player, damage them
  end

  def move_forward(player)
    # Figure out where the player is and where he is heading
    # Move them forward if empty, otherwise damage them, if driving into another player damege both
  end

  def turn(player, direction)
    # Change player direction
  end

  private

  def other_player(player)
    @players.reject{ |item| player }.first
  end
end

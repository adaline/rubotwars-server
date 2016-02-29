class Match
  attr_accessor :bots, :bot_keys
  attr_reader :last_move_key

  def initialize(bots)
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
    @map_width = 7
    @map_height = 7
    @bots = bots
    @bot_keys = []
    @last_move_key = nil
  end

  def start
    positions = []
    @map.each_with_index do |row, y|
      x = row.index(1)
      positions << [x, y] if x
    end
    positions.each_with_index do |position, index|
      b = @bots[index]
      b.x = position[0]
      b.y = position[1]
      b.save
      @bots[index] = b
      MatchChannel.broadcast_to(b, 'action' => 'start')
    end

    Seek.clear_all

    Thread.new do
      loop do
        Rails.logger.debug 'Queue tick'
        Match.load.bots.each do |m_bot|
          if m_bot.result.present?
            MatchChannel.broadcast_to(m_bot, 'action' => 'response', 'result' => m_bot.result.to_s)
            m_bot.result = nil
            m_bot.save
          end
        end
        sleep 1
      end
    end

  end

  def scan(bot)
    case bot.direction
    when 'left'
      if bot.x == 0
        bot.result = :wall
      else
        front_tile = @map[bot.y][bot.x - 1]
        if front_tile == 0 || front_tile == 1
          op = other_bot(bot)
          if op.x == bot.x - 1 && op.y = bot.y
            bot.result = :enemy
          else
            bot.result = :empty
          end
        elsif front_tile == 9
          bot.result = :wall
        end
      end
    when 'right'
      if bot.x == @map_width
        bot.result = :wall
      else
        front_tile = @map[bot.y][bot.x + 1]
        if front_tile == 0 || front_tile == 1
          op = other_bot(bot)
          if op.x == bot.x + 1 && op.y = bot.y
            bot.result = :enemy
          else
            bot.result = :empty
          end
        elsif front_tile == 9
          bot.result = :wall
        end
      end
    when 'up'
      if bot.y == 0
        bot.result = :wall
      else
        front_tile = @map[bot.y - 1][bot.x]
        if front_tile == 0 || front_tile == 1
          op = other_bot(bot)
          if op.x == bot.x && op.y = bot.y - 1
            bot.result = :enemy
          else
            bot.result = :empty
          end
        elsif front_tile == 9
          bot.result = :wall
        end
      end
    when 'down'
      if bot.y == @map_height
        bot.result = :wall
      else
        front_tile = @map[bot.y + 1][bot.x]
        if front_tile == 0 || front_tile == 1
          op = other_bot(bot)
          if op.x == bot.x && op.y = bot.y + 1
            bot.result = :enemy
          else
            bot.result = :empty
          end
        elsif front_tile == 9
          bot.result = :wall
        end
      end
    end
    bot.save
    @last_move_key = bot.key
  end

  def fire(bot)
    if scan(bot) == :enemy
      damage(other_bot(bot))
    end
    bot.result = true
    bot.save
    @last_move_key = bot.key
  end

  def move_forward(bot)
    scan_result = scan(bot)
    if scan_result == :wall
      damage(bot)
      bot.result = true
    elsif scan_result == :enemy
      damage(bot)
      damage(other_bot(bot))
      bot.result = true
    else
      case bot.direction
      when 'left'
        move(bot, -1, 0)
      when 'right'
        move(bot, +1, 0)
      when 'up'
        move(bot, 0, -1)
      when 'down'
        move(bot, 0, +1)
      end
    end
    @last_move_key = bot.key
  end

  def turn(bot, direction)
    @last_move_key = bot.key
    bot.turn(direction)
    bot.result = true
    bot.save
  end

  def save
    @bot_keys = bots.map(&:key)
    REDIS.set('rubot_match', YAML::dump(self))
  end

  def self.load
    loaded_match = YAML::load(REDIS.get('rubot_match'))
    loaded_match.bots = loaded_match.bot_keys.map { |b_key| Bot.load(b_key) }
    loaded_match
  end

  private

  def other_bot(bot)
    @bots.reject { |item| item == bot }.first
  end

  def damage(bot)
    bot.lives -= 1
    bot.save
  end

  def move(bot, dx, dy)
    bot.result = true
    bot.x += dx
    bot.y += dy
    bot.save
  end
end

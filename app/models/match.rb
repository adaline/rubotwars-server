class Match
  attr_accessor :bots, :bot_keys

  def initialize(bots)
    @map = [
      [1,0,0,9,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,9,0,0],
      [0,0,0,9,0,0,0,0,0,0],
      [0,0,9,0,0,0,0,0,0,9],
      [0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0],
      [9,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0],
      [0,0,9,0,0,0,0,9,0,0],
      [0,0,0,0,0,0,0,0,0,1]
    ]
    @bots = bots
    @bot_keys = []
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
    end

    MasterChannel.start(@bots, @map)

    @bots.each do |b|
      MatchChannel.broadcast_to(b, 'action' => 'start')
    end

    Seek.clear_all

    Thread.new do
      loop do
        last_move_index = REDIS.get('rubot_last_move').to_i

        bots = Match.load.bots
        bots.each do |b|
          if b.dead?
            Rails.logger.debug "Game over! #{b.name} is dead"
            MasterChannel.game_over(other_bot(b))
            Match.remove
            Thread.exit
          end
        end

        if bots[last_move_index].sent == true && bots[last_move_index].acknowledged == false
          last_bot = bots[last_move_index]
          if last_bot.result.present?
            MatchChannel.broadcast_to(last_bot, 'action' => 'response', 'result' => last_bot.result.to_s)
            last_bot.sent = true
            last_bot.save
          end
        else
          next_move_by = (last_move_index == 1) ? 0 : 1
          next_bot = bots[next_move_by]
          if next_bot.result.present? && next_bot.sent == false
            MatchChannel.broadcast_to(next_bot, 'action' => 'response', 'result' => next_bot.result.to_s)
            MasterChannel.update(bots, @map)
            next_bot.sent = true
            next_bot.acknowledged = false
            next_bot.save
          end
        end

        sleep 0.1
      end
    end

  end

  def scan2(bot, dx, dy)
    front_tile = @map[bot.y + dy][bot.x + dx]
    if front_tile == 0 || front_tile == 1
      ob = other_bot(bot)
      if (ob.x == bot.x + dx) && (ob.y == bot.y + dy)
        return :enemy
      else
        return :empty
      end
    elsif front_tile == 9
      return :wall
    end
  end


  def scan(bot)
    case bot.direction
    when 'left'
      if bot.x == 0
        return :wall
      else
        return scan2(bot, -1, 0)
      end
    when 'right'
      if bot.x == @map.first.count - 1
        return :wall
      else
        return scan2(bot, 1, 0)
      end
    when 'up'
      if bot.y == 0
        return :wall
      else
        return scan2(bot, 0, -1)
      end
    when 'down'
      if bot.y == @map.count - 1
        return :wall
      else
        return scan2(bot, 0, 1)
      end
    else
      puts "Unknown bot direction: #{bot.direction}"
    end
    MasterChannel.scan(bot)
  end

  def fire(bot)
    damage(other_bot(bot)) if scan(bot) == :enemy
    bot.result = true
    bot.save
    MasterChannel.fire(bot)
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
        move(bot, 1, 0)
      when 'up'
        move(bot, 0, -1)
      when 'down'
        move(bot, 0, 1)
      end
    end
  end

  def turn(bot, direction)
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

  def self.remove
    Match.load.bot_keys.each { |key| REDIS.del("rubot/#{key}") }
    REDIS.del('rubot_match')
  end

  private

  def other_bot(bot)
    @bots.reject { |item| item.key == bot.key }.first
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

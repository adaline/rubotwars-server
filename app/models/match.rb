class Match
  attr_accessor :bots, :bot_keys

  def initialize(bots)
    @map = Map::LEVELS[0]
    @bots = bots
    @bot_keys = []
  end

  def start
    positions = []
    @map.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        positions << [x, y] if cell == 1
      end
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
        bots = Match.load.bots
        bots.each do |b|
          if b.dead?
            Rails.logger.debug "Game over! #{b.name} is dead"
            MasterChannel.game_over(other_bot(b))
            Match.disconnnect_bots
            Match.remove
            Thread.exit
          end
        end

        last_move_index = REDIS.get('rubot_last_move').to_i
        next_move_by = (last_move_index == 1) ? 0 : 1
        next_bot = bots[next_move_by]

        if next_bot.result.present? && REDIS.scard('rubot_acknowledge_keys')
          acknowledge_key = SecureRandom.base64
          Rails.logger.debug "#{next_bot.key}: Sending result: #{next_bot.result.to_s}"
          MatchChannel.broadcast_to(next_bot, action: 'response', result: next_bot.result.to_s, acknowledge_key: acknowledge_key )
          MasterChannel.update(bots, @map)
          REDIS.set('rubot_last_move', next_move_by)
          REDIS.sadd('rubot_acknowledge_keys', acknowledge_key)
        end

        sleep 0.1
      end
    end
  end

  def scan(bot)
    MasterChannel.scan(bot)
    case bot.direction
    when 'left'
      (bot.x == 0) ? :wall : scan2(bot, -1, 0)
    when 'right'
      (bot.x == @map.first.count - 1) ? :wall : scan2(bot, 1, 0)
    when 'up'
      (bot.y == 0) ? :wall : scan2(bot, 0, -1)
    when 'down'
      (bot.y == @map.count - 1) ? :wall : scan2(bot, 0, 1)
    end
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
      bot.save
    elsif scan_result == :enemy
      damage(bot)
      damage(other_bot(bot))
      bot.result = true
      bot.save
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
    Rails.logger.debug 'Tried to load match but it no longer exists' unless Match.active?
    loaded_match = YAML::load(REDIS.get('rubot_match'))
    loaded_match.bots = loaded_match.bot_keys.map { |b_key| Bot.load(b_key) }
    loaded_match
  end

  def self.remove
    if Match.active?
      loaded_match = YAML::load(REDIS.get('rubot_match'))
      loaded_match.bot_keys.each do |key|
        REDIS.del("rubot/#{key}")
      end
      REDIS.del('rubot_match')
      REDIS.del('rubot_acknowledge_keys')
      REDIS.del('rubot_last_move')
    end
  end

  def self.active?
    REDIS.exists('rubot_match')
  end

  def self.disconnnect_bots
    match = Match.load
    match.bots.each do |bot|
      ActionCable.server.remote_connections.where(bot: bot).disconnect
    end
  end

  private

  def scan2(bot, dx, dy)
    front_tile = @map[bot.y + dy][bot.x + dx]
    if front_tile == 0 || front_tile == 1
      ob = other_bot(bot)
      ((ob.x == bot.x + dx) && (ob.y == bot.y + dy)) ? :enemy : :empty
    elsif front_tile == 9
      return :wall
    end
  end

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

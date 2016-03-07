class Seek
  def self.create(bot)
    if opponent = REDIS.spop('seeks')
      Match.remove
      match = Match.new([bot, Bot.load(opponent)])
      match.save
      match.start
    else
      REDIS.sadd('seeks', bot.key)
    end
  end

  def self.remove(bot)
    REDIS.srem('seeks', bot.key)
  end

  def self.clear_all
    REDIS.del('seeks')
  end
end

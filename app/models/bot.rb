class Bot
  attr_reader :name, :key
  attr_accessor :x, :y, :direction, :result, :lives

  DIRECTIONS = %w(left up right down)

  def initialize(name, key)
    @name = name
    @key = key
    @direction ||= DIRECTIONS.sample
    @x ||= 0
    @y ||= 0
    @lives ||= 3
    @result ||= nil
  end

  def save
    REDIS.set("rubot/#{key}", YAML::dump(self))
  end

  def self.load(key)
    YAML::load(REDIS.get("rubot/#{key}"))
  end

  def turn(directon)
    current_index = DIRECTIONS.index(@direction)
    if directon == :left
      new_index = current_index - 1
      if new_index < 0
        new_index = DIRECTIONS.length - 1
      end
    else
      new_index = current_index + 1
      if new_index > DIRECTIONS.length - 1
        new_index = 0
      end
    end
    puts "New directoion index: #{new_index}"
    @direction = DIRECTIONS[new_index]
  end

  def to_s
    @key
  end

  def dead?
    @lives == 0
  end
end

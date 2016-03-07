require 'redis'
REDIS = Redis.new
require File.expand_path('../../../app/models/bot', __FILE__)
require File.expand_path('../../../app/models/match', __FILE__)
Match.remove

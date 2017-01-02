require 'logger'
require 'singleton'

class FavLangLogger
  include Singleton

  def initialize
    @logger ||= Logger.new(STDOUT)
  end

  def self.log(level, msg)
    instance.log(level, msg)
  end

  def log(level, msg)
    @logger.send(level, msg)
  end

  def self.level=(level)
    instance.level = level
  end

  def level=(level)
    @logger.level = level
  end
end

require 'singleton'
require 'logger'

module Absurdity
  class Config
    include Singleton

    def redis
      @redis
    end

    def redis=(redis)
      @redis = redis
    end

    def logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def logger=(logger)
      @logger = logger
    end
  end
end

require 'singleton'

module Absurdity
  class Config
    include Singleton

    def redis
      @redis ||= Redis.new
    end

    def redis=(redis)
      @redis = redis
    end
  end
end

require 'minitest/autorun'
require 'mock_redis'
require 'absurdity'
require 'redis'
require 'mocha'

class MiniTest::Unit::TestCase

  def teardown
    Absurdity.redis && Absurdity.redis.flushdb
    Absurdity::Config.instance.instance_variable_set(:@redis, nil)
  end

end

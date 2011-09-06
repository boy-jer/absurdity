require 'minitest/autorun'
require 'mock_redis'
require 'absurdity'
require 'redis'
require 'mocha'

class MiniTest::Unit::TestCase

  def teardown
    Absurdity.redis.flushdb
  end

end

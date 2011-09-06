require 'test_helper'

class AbsurdityTest < MiniTest::Unit::TestCase

  def test_redis_getter_uninitialized
    ::Redis.expects(:new)

    Absurdity::Config.instance.redis
  end

  def test_redis_setter
    a_redis = MockRedis.new
    Absurdity::Config.instance.redis = a_redis

    assert_equal a_redis, Absurdity::Config.instance.redis
  end

end


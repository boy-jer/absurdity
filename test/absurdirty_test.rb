require 'test_helper'

class AbsurdityTest < MiniTest::Unit::TestCase

  def test_redis_getter_uninitialized
    Absurdity::Config.instance.expects(:redis)
    Absurdity.redis
  end

  def test_redis_setter
    Absurdity::Config.instance.expects(:redis=)
    Absurdity.redis = MockRedis.new
  end

end


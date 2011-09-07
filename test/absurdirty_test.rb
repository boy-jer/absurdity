require 'test_helper'

class AbsurdityTest < MiniTest::Unit::TestCase

  def test_redis_setter_and_getter
    a_redis = MockRedis.new
    Absurdity.redis = a_redis
    assert_equal a_redis, Absurdity.redis
  end

  def test_track_experiment_metric_with_variants
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.create(:shared_contacts_link,
                                [:clicked],
                                [:with_photos, :without_photos],
                                false)

    Absurdity.track! :clicked, :shared_contacts_link
  end

end


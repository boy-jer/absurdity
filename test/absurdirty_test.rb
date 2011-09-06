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

  def test_track_experiment_metric_without_variants
    Absurdity::Experiment.create(:shared_contacts_link,
                                [:clicked],
                                [:with_photos, :without_photos],
                                false)

    Absurdity.track! :clicked, :shared_contacts_link
  end

end


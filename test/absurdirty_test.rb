require 'test_helper'

class AbsurdityTest < MiniTest::Unit::TestCase

  def test_redis_setter_and_getter
    a_redis = MockRedis.new
    Absurdity.redis = a_redis
    assert_equal a_redis, Absurdity.redis
  end

  def test_track_experiment_metric_without_variants
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.create(:shared_contacts_link,
                                [:clicked],
                                [])

    Absurdity.track! :clicked, :shared_contacts_link
    assert_equal 1, Absurdity.count(:clicked, :shared_contacts_link)
  end

  def test_track_experiment_metric_with_variants
    Absurdity.redis = MockRedis.new
    # give identity_id 1 the with_photos variant

    Absurdity::Experiment.create(:shared_contacts_link,
                                [:clicked],
                                [:with_photos, :without_photos])

    Absurdity.track! :clicked, :shared_contacts_link, 1
    count = Absurdity.count(:clicked, :shared_contacts_link)

    assert_equal 1, count[:with_photos]
    assert_equal 0, count[:without_photos]
  end

end


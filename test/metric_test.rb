require 'test_helper'

class MetricTest < MiniTest::Unit::TestCase

  def setup
    Absurdity.redis = MockRedis.new
  end

  def test_track_metric
    experiment = :shared_contacts_link
    metric = :clicked
    key = "#{experiment}:#{metric}"

    metric = Absurdity::Metric.new(metric, experiment)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

  def test_track_variant_metric
    experiment = :shared_contacts_link
    metric = :clicked
    variant = :with_photos
    # identity_id = 1


    metric = Absurdity::Metric.new(metric, experiment, variant)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

end


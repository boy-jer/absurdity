require 'test_helper'

class MetricTest < MiniTest::Unit::TestCase

  def setup
    Absurdity.redis = MockRedis.new
  end

  def test_track_simple_metric
    metric = :clicked
    key = metric.to_s

    assert_nil Absurdity::Metric.count(key)
    Absurdity::Metric.track! metric
    assert_equal "1", Absurdity::Metric.count(key)
    Absurdity::Metric.track! metric
    assert_equal "2", Absurdity::Metric.count(key)
  end

  def test_track_scoped_metric
    experiment = :wicked
    metric = :clicked
    key = "#{experiment}:#{metric}"

    assert_nil Absurdity::Metric.count(key)
    Absurdity::Metric.track! metric, experiment: experiment
    assert_equal "1", Absurdity::Metric.count(key)
  end

  def test_track_scoped_variant_metric
    experiment = :wicked
    metric = :clicked
    variants = [:with_sweetness, :without_sweetness]
    identity_id = 1

    Absurdity::Metric.track! metric,
                             experiment: experiment,
                             variants: variants,
                             identity_id: identity_id

    variant = Absurdity::Metric.variant_for(experiment,
                                            identity_id,
                                            variants)
    key = "#{experiment}:#{variant}:#{metric}"

    assert_equal "1", Absurdity::Metric.count(key)
  end

end


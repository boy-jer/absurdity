require 'test_helper'

class MetricTest < MiniTest::Unit::TestCase

  def setup
    Absurdity.redis = MockRedis.new
  end

  def test_find_and_create
    experiment_slug  = :shared_contacts_link
    metric_slug      = :clicked
    experiment = stub(slug: experiment_slug, metrics_list: [metric_slug])
    Absurdity::Datastore.stubs(:find_experiment).returns(experiment)

    metric = Absurdity::Metric.create(metric_slug, experiment_slug)

    assert_equal metric, Absurdity::Metric.find(metric_slug, experiment_slug)
  end

  def test_find_not_found
    assert_raises Absurdity::Metric::NotFoundError do
      Absurdity::Metric.find(:blah, :boo)
    end
  end

  def test_save_first_time
    experiment_slug  = :shared_contacts_link
    metric_slug      = :clicked
    experiment = stub(slug: experiment_slug, metrics_list: [metric_slug])
    Absurdity::Datastore.stubs(:find_experiment).returns(experiment)

    metric = Absurdity::Metric.new(metric_slug, experiment_slug)

    metric.save
    assert_equal metric, Absurdity::Metric.find(metric_slug, experiment_slug)
  end

  def test_save_after_first_time
    experiment_slug  = :shared_contacts_link
    metric_slug      = :clicked
    metric = Absurdity::Metric.create(metric_slug, experiment_slug)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
    metric.save
    assert_equal 1, metric.count
  end

  def test_count
    experiment_slug  = :shared_contacts_link
    metric_slug      = :clicked
    metric = Absurdity::Metric.create(metric_slug, experiment_slug)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

  def test_track_metric
    experiment_slug = :shared_contacts_link
    metric_slug     = :clicked

    metric = Absurdity::Metric.new(metric_slug, experiment_slug)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

  def test_track_variant_metric
    experiment_slug = :shared_contacts_link
    metric_slug     = :clicked
    variant_slug    = :with_photos
    metric = Absurdity::Metric.new(metric_slug, experiment_slug, variant_slug)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

end


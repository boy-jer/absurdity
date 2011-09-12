require 'test_helper'

class MetricTest < MiniTest::Unit::TestCase

  def setup
    Absurdity.redis = MockRedis.new
  end

  def test_find_and_create
    experiment  = :shared_contacts_link
    metric_slug = :clicked
    metric = Absurdity::Metric.create(metric_slug, experiment)

    assert_equal metric, Absurdity::Metric.find(metric_slug, experiment)
  end

  def test_find_not_found
    assert_raises Absurdity::Metric::NotFoundError do
      Absurdity::Metric.find(:blah, :boo)
    end
  end

  def test_save_first_time
    experiment  = :shared_contacts_link
    metric_slug = :clicked
    metric = Absurdity::Metric.new(metric_slug, experiment)

    assert_nil Absurdity.redis.get(metric.key)
    metric.save
    assert_equal "0", Absurdity.redis.get(metric.key)
  end

  def test_save_after_first_time
    experiment  = :shared_contacts_link
    metric_slug = :clicked
    metric = Absurdity::Metric.create(metric_slug, experiment)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
    metric.save
    assert_equal 1, metric.count
  end

  def test_count
    experiment  = :shared_contacts_link
    metric_slug = :clicked
    metric = Absurdity::Metric.create(metric_slug, experiment)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

  def test_key
    experiment  = :shared_contacts_link
    metric_slug = :clicked
    variant     = :with_photos

    metric = Absurdity::Metric.new(metric_slug, experiment)
    assert_equal "#{experiment}:#{metric_slug}", metric.key

    metric = Absurdity::Metric.new(metric_slug, experiment, variant)
    assert_equal "#{experiment}:#{variant}:#{metric_slug}", metric.key
  end

  def test_track_metric
    experiment = :shared_contacts_link
    metric_slug = :clicked

    metric = Absurdity::Metric.new(metric_slug, experiment)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

  def test_track_variant_metric
    experiment = :shared_contacts_link
    metric = :clicked
    variant = :with_photos
    metric = Absurdity::Metric.new(metric, experiment, variant)

    assert_equal 0, metric.count
    metric.track!
    assert_equal 1, metric.count
  end

end


require 'test_helper'

class AbsurdityTest < MiniTest::Unit::TestCase

  def test_redis_setter_and_getter
    a_redis = MockRedis.new
    Absurdity.redis = a_redis
    assert_equal a_redis, Absurdity.redis
  end

  def test_track_missing_experiment
    Absurdity.redis = MockRedis.new

    assert_raises Absurdity::Experiment::NotFoundError do
      Absurdity.track! :clicked, :shared_contacts_link
    end
  end

  def test_track_missing_metric
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.create(:shared_contacts_link,
                                 [:clicked])

    assert_raises Absurdity::Metric::NotFoundError do
      Absurdity.track! :seen, :shared_contacts_link
    end
  end

  def test_track_missing_identity_id
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.create(:shared_contacts_link,
                                 [:clicked],
                                 [:with_photos, :without_photos])

    assert_raises Absurdity::MissingIdentityIDError do
      Absurdity.track! :seen, :shared_contacts_link
    end
  end

  def test_track_experiment_metric_without_variants
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.create(:shared_contacts_link,
                                 [:clicked])

    Absurdity.track! :clicked, :shared_contacts_link
    assert_equal 1, Absurdity.count(:clicked, :shared_contacts_link)
  end

  def test_track_experiment_metric_with_variants
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.any_instance.expects(:random_variant).returns(:with_photos)

    Absurdity::Experiment.create(:shared_contacts_link,
                                [:clicked],
                                [:with_photos, :without_photos])

    Absurdity.track! :clicked, :shared_contacts_link, 1
    count = Absurdity.count(:clicked, :shared_contacts_link)

    assert_equal 1, count[:with_photos]
    assert_equal 0, count[:without_photos]
  end

  def test_track_experiment_with_multiple_metrics_with_variants
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.any_instance.expects(:random_variant).returns(:with_photos)

    Absurdity::Experiment.create(:shared_contacts_link,
                                 [:clicked, :seen],
                                 [:with_photos, :without_photos])

    Absurdity.track! :clicked, :shared_contacts_link, 1
    Absurdity.track! :seen, :shared_contacts_link, 1
    count = Absurdity.count(:clicked, :shared_contacts_link)

    assert_equal 1, count[:with_photos]
    assert_equal 0, count[:without_photos]

    count = Absurdity.count(:seen, :shared_contacts_link)
    assert_equal 1, count[:with_photos]
    assert_equal 0, count[:without_photos]
  end

  def test_variant
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.any_instance.expects(:random_variant).returns(:with_photos)

    Absurdity::Experiment.create(:shared_contacts_link,
                                 [:clicked, :seen],
                                 [:with_photos, :without_photos])

    assert_equal :with_photos, Absurdity.variant(:shared_contacts_link, 1)
  end

  def test_report_hash
    Absurdity.redis = MockRedis.new
    Absurdity::Experiment.any_instance.expects(:random_variant).returns(:with_photos)

    Absurdity::Experiment.create(:shared_contacts_link,
                                 [:clicked, :seen],
                                 [:with_photos, :without_photos])

    2.times { Absurdity.track!(:clicked, :shared_contacts_link, 1) }
    5.times { Absurdity.track!(:seen, :shared_contacts_link, 1) }

    expected_report = [
      {
        name: :shared_contacts_link,
        completed: nil,
        data: {
          with_photos: {
            clicked: 2,
            seen:    5
          },
          without_photos: {
            clicked: 0,
            seen:    0
          }
        }
      }
    ]
    assert_equal expected_report, Absurdity.reports
  end
end


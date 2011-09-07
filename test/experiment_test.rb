require 'test_helper'

class ExperimentTest < MiniTest::Unit::TestCase

  def setup
    @experiment_slug = :shared_contacts_link
    @metrics         = [:clicked, :seen]
    @variants        = [:with_photos, :without_photos]
    @identity_based  = true
    Absurdity.redis = MockRedis.new
  end

  def test_find_and_test_create
    experiment = Absurdity::Experiment.create(@experiment_slug,
                                              @metrics,
                                              @variants)

    assert_equal experiment, Absurdity::Experiment.find(@experiment_slug)
  end

  def test_initialize
    experiment = Absurdity::Experiment.new(@experiment_slug)
  end

  def test_metric

  end

end


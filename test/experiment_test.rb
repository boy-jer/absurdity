require 'test_helper'

class ExperimentTest < MiniTest::Unit::TestCase

  def setup
    @experiment_slug = :shared_contacts_link
    @metric_slugs    = [:clicked, :seen]
    @variant_slugs   = [:with_photos, :without_photos]
    Absurdity.redis  = MockRedis.new
  end

  def test_find_and_test_create
    experiment = Absurdity::Experiment.create(@experiment_slug,
                                              @metric_slugs,
                                              @variant_slugs)

    assert_equal experiment, Absurdity::Experiment.find(@experiment_slug)
  end

  def test_initialize
    # crappy test
    experiment = Absurdity::Experiment.new(@experiment_slug,
                                           metric_slugs:  @metric_slugs,
                                           variant_slugs: @variant_slugs)
  end

  def test_save

  end

  def test_metric

  end

end


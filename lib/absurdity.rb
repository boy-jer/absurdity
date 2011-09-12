require 'json'

module Absurdity
  class MissingIdentityIDError < RuntimeError; end

  autoload :Metric,     "absurdity/metric"
  autoload :Config,     "absurdity/config"
  autoload :Experiment, "absurdity/experiment"

  def self.redis
    Config.instance.redis
  end

  def self.redis=(redis)
    Config.instance.redis = redis
  end

  def self.track!(metric, experiment, identity_id=nil)
    experiment = Experiment.find(experiment)
    experiment.track!(metric, identity_id)
  end

  def self.count(metric, experiment)
    experiment = Experiment.find(experiment)
    experiment.count(metric)
  end

  def self.variant(experiment, identity_id)
    experiment = Experiment.find(experiment)
    experiment.variant_for(identity_id)
  end
end

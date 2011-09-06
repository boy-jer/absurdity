require 'json'

module Absurdity

  autoload :Metric,     "absurdity/metric"
  autoload :Config,     "absurdity/config"
  autoload :Experiment, "absurdity/experiment"

  def self.redis
    Config.instance.redis
  end

  def self.redis=(redis)
    Config.instance.redis = redis
  end

  def self.track!(metric, experiment)
    experiment = Experiment.find(experiment)
    experiment.metric(metric).track!
  end
end

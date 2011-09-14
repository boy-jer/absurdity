require 'json'
require 'absurdity/railtie.rb' if defined?(Rails)
require 'absurdity/engine' if defined?(Rails)

module Absurdity
  class MissingIdentityIDError < RuntimeError; end

  autoload :Config,     "absurdity/config"
  autoload :Experiment, "absurdity/experiment"
  autoload :Metric,     "absurdity/metric"
  autoload :Variant,    "absurdity/variant"
  autoload :Datastore,  "absurdity/datastore"

  def self.redis
    Config.instance.redis
  end

  def self.redis=(redis)
    Config.instance.redis = redis
  end

  def self.track!(metric_slug, experiment_slug, identity_id=nil)
    Experiment.find(experiment_slug).track!(metric_slug, identity_id)
  end

  def self.count(metric_slug, experiment_slug)
    Experiment.find(experiment_slug).count(metric_slug)
  end

  def self.variant(experiment_slug, identity_id)
    Experiment.find(experiment_slug).variant_for(identity_id)
  end

  def self.report
    Experiment.report
  end

  def self.new_experiment(experiment_slug, metric_slugs, variant_slugs=nil)
    begin
      experiment = Experiment.find(experiment_slug)
    rescue Experiment::NotFoundError
      Experiment.create(experiment_slug, metric_slugs, variant_slugs)
    end
  end

end

module Absurdity
  class Metric
    class NotFoundError < RuntimeError; end

    def self.create(slug, experiment, variant=nil)
      metric = new(slug, experiment, variant)
      metric.save
      metric
    end

    def self.find(slug, experiment, variant=nil)
      metric = new(slug, experiment, variant)
      raise NotFoundError unless Absurdity.redis.exists(metric.key)
      metric
    end

    attr_reader :slug, :variant
    def initialize(slug, experiment, variant=nil)
      @slug       = slug
      @experiment = experiment
      @variant    = variant
    end

    def save
      # this keeps us from resetting a metric to 0
      redis.get(key) || redis.set(key, 0)
    end

    def track!
      redis.set(key, count + 1)
    end

    def count
      redis.get(key).to_i
    end

    def key
      key = @experiment.to_s
      key += variant ? ":#{variant}" : ""
      key += ":#{slug}"
      key
    end

    def ==(other_metric)
      slug        == other_metric.slug                                &&
      @experiment == other_metric.instance_variable_get(:@experiment) &&
      variant     == other_metric.variant
    end


    private

    def redis
      Absurdity.redis
    end

  end
end

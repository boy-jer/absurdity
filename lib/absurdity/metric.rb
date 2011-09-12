module Absurdity
  class Metric
    class NotFoundError < RuntimeError; end

    def self.create(metric, experiment, variant=nil)
      metric = new(metric, experiment, variant)
      metric.save
      metric
    end

    def self.find(metric, experiment, variant=nil)
      metric = new(metric, experiment, variant)
      raise NotFoundError unless Absurdity.redis.exists(metric.key)
      metric
    end

    def initialize(metric, experiment, variant=nil)
      @metric     = metric
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
      key += @variant ? ":#{@variant}" : ""
      key += ":#{@metric.to_s}"
      key
    end

    def ==(other_metric)
      @metric     == other_metric.instance_variable_get(:@metric)     &&
      @experiment == other_metric.instance_variable_get(:@experiment) &&
      @variant    == other_metric.instance_variable_get(:@variant)
    end


    private

    def redis
      Absurdity.redis
    end

  end
end

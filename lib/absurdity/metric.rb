module Absurdity
  class Metric
    class NotFoundError < RuntimeError; end

    def self.create(metric, experiment, variant=nil)
      new(metric, experiment, variant).save
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
      redis.get(key) || redis.set(key, 0)
    end

    def track!
      redis.set(key, (count || 0).to_i + 1)
    end

    def count
      (redis.get(key) || 0).to_i
    end

    def key
      key = @experiment.to_s
      key += @variant ? ":#{@variant}" : ""
      key += ":#{@metric.to_s}"
      key
    end

    private

    def redis
      Absurdity.redis
    end

  end
end

module Absurdity
  class Metric

    def self.find(metric, experiment, variant=nil)
      new(metric, experiment, variant)
    end

    def initialize(metric, experiment, variant=nil)
      @metric     = metric
      @experiment = experiment
      @variant    = variant
    end

    def track!(identity_id = nil)
      @identity_id = identity_id
      redis.set(key, (count || 0).to_i + 1)
    end

    def count
      (redis.get(key) || 0).to_i
    end

    private

    def redis
      Absurdity.redis
    end

    def key
      key = @experiment.to_s
      key += @variant ? ":#{@variant}" : ""
      key += ":#{@metric.to_s}"
      key
    end

  end
end

module Absurdity
  class Metric

    def self.find(metric, experiment)
      new(metric, experiment)
    end

    def initialize(metric, experiment)
      @metric     = metric
      @experiment = experiment
    end

    def track!(identity_id = nil)
      @identity_id = identity_id
      redis.set(key, (count || 0).to_i + 1)
    end

    def self.variant_for(experiment, identity_id, variants)
      key = "#{experiment}:#{identity_id}:variant"
      variant = redis.get(key)
      if variant.nil?
        redis.set(key, variants.first)
        variant = redis.get(key)
      end
      variant
    end

    def count
      redis.get(key)
    end

    private

    def self.redis
      Absurdity.redis
    end

    def key
      key = experiment.to_s
      key += experiment.has_variants? ? ":#{experiment.variant_for(@identity_id)}" : ""
      key += ":#{metric.to_s}"
      key
    end

  end
end

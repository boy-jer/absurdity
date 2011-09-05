module Absurdity
  class Metric

    def self.track!(metric, options = {})
      redis.set(key(metric, options), (count(key(metric, options)) || 0).to_i + 1)
    end

    def self.variant_for(options = {})
      key = "#{options[:experiment]}:#{options[:variant_id]}:variant"
      variant = redis.get(key)
      if variant.nil?
        redis.set(key, options[:variants].first)
        variant = redis.get(key)
      end
      variant
    end

    def self.count(key)
      redis.get(key)
    end

    private

    def self.redis
      Absurdity.redis
    end

    def self.key(metric, options)
      key = options[:experiment] ? "#{options[:experiment]}:" : ""
      key += options[:variants] ? "#{variant_for(options)}:" : ""
      key += metric.to_s
      key
    end

  end
end

module Absurdity
  class Experiment

    def self.create(slug, metrics, variants, identity_based)
      base_key = base_key(slug)
      Config.instance.redis.set("#{base_key}:metrics", metrics.to_json)
      Config.instance.redis.set("#{base_key}:variants", variants.to_json)
      Config.instance.redis.set("#{base_key}:identity_based", identity_based)
      new(slug)
    end

    def self.find(slug)
      new(slug)
    end

    attr_reader :slug, :metrics, :variants
    def initialize(slug)
      @slug           = slug
    end

    def metric(metric_slug)
      metric_slug = metrics.find { |m| m == metric_slug }
      Metric.find("#{@slug}:#{metric_slug}")
    end

    def ==(other_experiment)
      slug            == other_experiment.slug &&
      metrics         == other_experiment.metrics &&
      variants        == other_experiment.variants &&
      identity_based? == other_experiment.identity_based?
    end

    def metrics
      @metrics ||= get_metrics
    end

    def variants
      @variants ||= get_variants
    end

    def identity_based?
      @identity_based ||= get_identity_based
    end

    def has_variants?
      variants
    end

    private

    def self.base_key(slug)
      "experiments:#{slug}"
    end

    def base_key
      self.class.base_key(slug)
    end

    def get_variants
      JSON.parse(Config.instance.redis.get("#{base_key}:variants")).map { |v| v.to_sym }
    end

    def get_metrics
      JSON.parse(Config.instance.redis.get("#{base_key}:metrics")).map { |m| m.to_sym }
    end

    def get_identity_based
      Config.instance.redis.get("#{base_key}:identity_based") == "true"
    end
  end
end

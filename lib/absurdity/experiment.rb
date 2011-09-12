module Absurdity
  class Experiment

    def self.create(slug, metrics, variants=[])
      base_key = base_key(slug)
      Config.instance.redis.set("#{base_key}:metrics", metrics.to_json)
      Config.instance.redis.set("#{base_key}:variants", variants.to_json)
      new(slug)
    end

    def self.find(slug)
      new(slug)
    end

    attr_reader :slug, :metrics, :variants
    def initialize(slug)
      @slug = slug
    end

    def track!(metric_slug, identity_id=nil)
      variant = identity_id ? variant_for(identity_id) : nil
      metric(metric_slug, variant).track!
    end

    def count(metric_slug)
      if !variants.empty?
        count = {}
        variants.each do |variant|
          count[variant] = metric(metric_slug, variant).count
        end
      else
        count = metric(metric_slug).count
      end
      count
    end

    def metric(metric_slug, variant=nil)
      metric_slug = metrics.find { |m| m == metric_slug }
      Metric.find(metric_slug, @slug, variant)
    end

    def ==(other_experiment)
      slug            == other_experiment.slug &&
      metrics         == other_experiment.metrics &&
      variants        == other_experiment.variants
    end

    def metrics
      @metrics ||= get_metrics
    end

    def variants
      @variants ||= get_variants
    end

    def identity_based?
      @identity_based ||= variants && !variants.empty?
    end

    def variant_for(identity_id)
      variant = Config.instance.redis.get("#{base_key}:identity_id:#{identity_id}:variant")
      if variant.nil?
        variant = random_variant
        Config.instance.redis.set("#{base_key}:identity_id:#{identity_id}:variant", variant)
      end
      variant
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

    def random_variant
      variants.sort_by{rand}[0]
    end
  end
end

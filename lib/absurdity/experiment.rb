module Absurdity
  class Experiment
    class NotFoundError < RuntimeError; end

    def self.create(slug, metrics, variants=[])
      experiment = new(slug, metrics, variants)
      experiment.save
      experiment
    end

    def self.find(slug)
      experiment = new(slug)
      raise NotFoundError if experiment.metrics.nil?
      experiment
    end

    attr_reader :slug
    def initialize(slug, metric_slugs=nil, variant_slugs=[])
      @slug          = slug
      @metric_slugs  = metric_slugs
      @variant_slugs = variant_slugs
    end

    def save
      create_variants
      create_metrics
    end

    def track!(metric_slug, identity_id=nil)
      raise Absurdity::MissingIdentityIDError if identity_based? && identity_id.nil?
      variant = identity_based? ? variant_for(identity_id) : nil
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
      variant.to_sym
    end

    private

    def create_metrics
      Config.instance.redis.set("#{base_key}:metrics", @metric_slugs.to_json)
      @metric_slugs.each do |metric_slug|
        if !@variant_slugs.empty?
          @variant_slugs.each do |variant_slug|
            Metric.create(metric_slug, slug, variant_slug)
          end
        else
          Metric.create(metric_slug, slug)
        end
      end
    end

    def create_variants
      if !@variant_slugs.empty?
        Config.instance.redis.set("#{base_key}:variants", @variant_slugs.to_json)
      end
    end

    def base_key
      "experiments:#{slug}"
    end

    def get_variants
      metrics_json_string = Config.instance.redis.get("#{base_key}:variants")
      if !metrics_json_string.nil?
        JSON.parse(metrics_json_string).map { |v| v.to_sym }
      else
        []
      end
    end

    def get_metrics
      metrics_json_string = Config.instance.redis.get("#{base_key}:metrics")
      if !metrics_json_string.nil?
        JSON.parse(metrics_json_string).map { |m| m.to_sym }
      else
        metrics_json_string
      end
    end

    def random_variant
      variants.sort_by{rand}[0]
    end
  end
end

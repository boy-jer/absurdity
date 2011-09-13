module Absurdity
  class Experiment
    class NotFoundError < RuntimeError; end
    class FoundError < RuntimeError; end

    def self.create(slug, metrics, variants=[])
      raise FoundError if experiments_list.find { |e| e == slug }
      experiment = new(slug, metrics, variants)
      experiment.save
      experiment
    end

    def self.find(slug)
      raise NotFoundError unless experiments_list.find { |e| e == slug }
      experiment = new(slug)
      experiment
    end

    def self.all
      experiments_list.map { |exp| new(exp) }
    end

    attr_reader :slug
    def initialize(slug, metric_slugs=nil, variant_slugs=[])
      @slug          = slug
      @metric_slugs  = metric_slugs
      @variant_slugs = variant_slugs
    end

    def save
      add_to_experiments_list
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

    def self.experiments_list
      json_string = Config.instance.redis.get("experiments_list")
      !json_string.nil? ? JSON.parse(json_string).map { |m| m.to_sym } : []
    end

    def add_to_experiments_list
      Config.instance.redis.set("experiments_list", (self.class.experiments_list << slug).to_json)
    end

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
      json_string = Config.instance.redis.get("#{base_key}:variants")
      if !json_string.nil?
        JSON.parse(json_string).map { |v| v.to_sym }
      else
        []
      end
    end

    def get_metrics
      json_string = Config.instance.redis.get("#{base_key}:metrics")
      if !json_string.nil?
        JSON.parse(json_string).map { |m| m.to_sym }
      else
        json_string
      end
    end

    def random_variant
      variants.sort_by{rand}[0]
    end
  end
end

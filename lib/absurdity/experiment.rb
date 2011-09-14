module Absurdity
  class Experiment
    class NotFoundError < RuntimeError; end
    class FoundError < RuntimeError; end

    def self.create(slug, metric_slugs, variant_slugs=nil)
      raise FoundError if Datastore.find_experiment(slug)
      experiment = new(slug, metric_slugs: metric_slugs, variant_slugs: variant_slugs)
      experiment.save
      experiment
    end

    def self.find(slug)
      raise NotFoundError unless experiment = Datastore.find_experiment(slug)
      experiment
    end

    def self.report
      all.map { |exp| exp.report }
    end

    def self.all
      Datastore.all_experiments
    end

    attr_reader :slug, :attributes
    def initialize(slug, attributes = {})
      @slug       = slug
      @attributes = attributes
    end

    def report
      report = {}
      report[slug] = {}
      if variants?
        variants.each do |variant|
          report[slug][variant] = {}
          metric_slugs.each do |metric_slug|
            report[slug][variant][metric_slug] = metric(metric_slug, variant).count
          end
        end
      else
        metric_slugs.each do |metric_slug|
          report[slug][metric_slug] = metric(metric_slug).count
        end
      end
      report
    end

    def save
      Datastore.save_experiment(self)
    end

    def track!(metric_slug, identity_id=nil)
      raise Absurdity::MissingIdentityIDError if variants? && identity_id.nil?
      variant = variants? ? variant_for(identity_id) : nil
      metric(metric_slug, variant).track!
    end

    def count(metric_slug)
      if !variants.nil?
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
      Metric.find(metric_slug, slug, variant)
    end

    def ==(other_experiment)
      slug            == other_experiment.slug &&
      metrics         == other_experiment.metrics &&
      variants        == other_experiment.variants
    end

    def metrics
      return @metrics unless @metrics.nil?
      @metrics = []
      metric_slugs.each do |metric_slug|
        if !variants.nil?
          variants.each { |variant| @metrics << metric(metric_slug, variant) }
        else
          @metrics << metric(metric_slug)
        end
      end
      @metrics
    end

    def variants
      @variants ||= variant_slugs
    end

    def variants?
      variants && !variants.nil?
    end

    def variant_for(identity_id)
      key = "identity_id:#{identity_id}:variant"
      variant = Datastore.get(key, experiment: self)
      if variant.nil?
        variant = random_variant
        Datastore.set(key, variant, experiment: self)
      end
      variant.to_sym
    end

    def metric_slugs
      attributes[:metric_slugs] ||= Datastore.get(:metric_slugs, experiment: self)
    end

    def variant_slugs
      attributes[:variant_slugs] ||= Datastore.get(:variant_slugs, experiment: self)
    end

    private

    def random_variant
      variants.sort_by { rand }[0]
    end

  end
end

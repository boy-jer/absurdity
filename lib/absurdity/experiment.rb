module Absurdity
  class Experiment
    class NotFoundError < RuntimeError; end
    class FoundError < RuntimeError; end

    def self.create(slug, metrics_list, variants_list=nil)
      raise FoundError if Datastore.find(self, slug: slug)
      experiment = new(slug, metrics_list: metrics_list, variants_list: variants_list)
      experiment.save
      experiment
    end

    def self.find(slug)
      raise NotFoundError unless experiment = Datastore.find(self, slug: slug)
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
        variants_list.each do |variant|
          report[slug][variant] = {}
          metrics_list.each do |metric_slug|
            report[slug][variant][metric_slug] = metric(metric_slug, variant).count
          end
        end
      else
        metrics_list.each do |metric_slug|
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
      if variants?
        count = {}
        variants_list.each do |variant|
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
      slug            == other_experiment.slug         &&
      metrics_list    == other_experiment.metrics_list &&
      variants_list   == other_experiment.variants_list
    end

    def metrics
      return @metrics unless @metrics.nil?
      @metrics = []
      metrics_list.each do |metric_slug|
        if variants?
          variants_list.each { |variant| @metrics << metric(metric_slug, variant) }
        else
          @metrics << metric(metric_slug)
        end
      end
      @metrics
    end

    def variant_for(identity_id)
      variant = Variant.find(identity_id, slug)
      if variant.nil?
        variant = Variant.new(random_variant, slug, identity_id)
        variant.save
      end
      variant.slug
    end

    def metrics_list
      attributes[:metrics_list]
    end

    def variants_list
      attributes[:variants_list]
    end

    def variants?
      variants_list
    end

    private

    def random_variant
      variants_list.sort_by { rand }[0]
    end

  end
end

module Absurdity
  class Metric
    class NotFoundError < RuntimeError; end

    def self.create(slug, experiment_slug, variant_slug=nil)
      metric = new(slug, experiment_slug, variant_slug)
      metric.save
      metric
    end

    def self.find(slug, experiment_slug, variant_slug=nil)
      raise NotFoundError unless metric = Datastore.find_metric(slug, experiment_slug, variant_slug)
      metric
    end

    attr_reader :slug, :experiment_slug, :variant_slug
    def initialize(slug, experiment_slug, variant_slug=nil)
      @slug            = slug
      @experiment_slug = experiment_slug
      @variant_slug    = variant_slug
    end

    def save
      Datastore.save_metric(self)
    end

    def track!
      Datastore.inc_metric_count(self)
    end

    def count
      Datastore.metric_count(self)
    end

    def key
      key = variant_slug ? "#{variant_slug}" : ""
      key += ":#{slug}"
      key
    end

    def ==(other_metric)
      slug            == other_metric.slug            &&
      experiment_slug == other_metric.experiment_slug &&
      variant_slug    == other_metric.variant_slug
    end

    private

    def redis
      Absurdity.redis
    end

  end
end

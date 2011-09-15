module Absurdity
  class Metric
    class NotFoundError < RuntimeError; end

    def self.create(slug, experiment_slug, variant_slug=nil)
      metric = new(slug, experiment_slug, variant_slug)
      metric.save
      metric
    end

    def self.find(slug, experiment_slug, variant_slug=nil)
      raise NotFoundError unless metric = Datastore.find(self,
                                                         slug:            slug,
                                                         experiment_slug: experiment_slug,
                                                         variant_slug:    variant_slug)
      metric
    end

    attr_reader :slug, :experiment_slug, :variant_slug
    def initialize(slug, experiment_slug, variant_slug=nil)
      @slug            = slug
      @experiment_slug = experiment_slug
      @variant_slug    = variant_slug
    end

    def save
      Datastore.save(self)
    end

    def track!
      @count += 1
      save
    end

    def count
      @count ||= 0
    end

    def ==(other_metric)
      slug            == other_metric.slug            &&
      experiment_slug == other_metric.experiment_slug &&
      variant_slug    == other_metric.variant_slug
    end

  end
end

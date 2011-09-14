module Absurdity
  class Variant

    attr_reader :slug, :experiment_slug
    def initialize(slug, experiment_slug)
      @slug            = slug
      @experiment_slug = experiment_slug
    end

  end
end
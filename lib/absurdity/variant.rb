module Absurdity
  class Variant

    def self.find(identity_id, experiment_slug)
      Datastore.find(self, experiment_slug: experiment_slug, identity_id: identity_id)
    end

    attr_reader :slug, :experiment_slug, :identity_id
    def initialize(slug, experiment_slug, identity_id)
      @slug            = slug
      @experiment_slug = experiment_slug
      @identity_id     = identity_id
    end

    def save
      Datastore.save(self)
    end

  end
end
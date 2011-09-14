module Absurdity
  class Datastore

    PARSE_AS_JSON = [
      :metric_slugs,
      :variant_slugs,
      :experiments_list
    ]

    def self.get(key, options={})
      if experiment = options[:experiment]
        string = redis.get("experiments:#{experiment.slug}:#{key}")
      else
        string = redis.get("experiments:#{key}")
      end
      if PARSE_AS_JSON.include?(key)
        string && JSON.parse(string).map { |v| v.to_sym }
      else
        string
      end
    end

    def self.set(key, value, options={})
      if experiment = options[:experiment]
        redis.set("experiments:#{experiment.slug}:#{key}", value.to_json)
      else
        redis.set("experiments:#{key}", value)
      end
    end

    def self.save_experiment(experiment)
      add_to_experiments_list(experiment.slug)
      create_variants(experiment)
      create_metrics(experiment)
    end

    def self.find_experiment(experiment_slug)
      return nil unless slug = experiments_list.find { |e| e == experiment_slug }
      Experiment.new(slug)
    end

    def self.save_metric(metric)
      return if find_metric(metric.slug, metric.experiment_slug, metric.variant_slug)
      set(metric.key, 0, experiment: find_experiment(metric.experiment_slug))
    end

    def self.find_metric(metric_slug, experiment_slug, variant_slug)
      experiment = find_experiment(experiment_slug)
      return nil unless experiment && experiment.metric_slugs.find { |sl| sl == metric_slug }
      Metric.new(metric_slug, experiment_slug, variant_slug)
    end

    def self.inc_metric_count(metric)
      experiment = find_experiment(metric.experiment_slug)
      count = get(metric.key, experiment: experiment).to_i
      set(metric.key, count + 1, experiment: experiment)
    end

    def self.metric_count(metric)
      experiment = find_experiment(metric.experiment_slug)
      get(metric.key, experiment: experiment).to_i
    end

    def self.all_experiments
      experiments_list.map { |exp| Experiment.new(exp) }
    end

    private

    def self.redis
      Config.instance.redis
    end

    def self.experiments_list
      get(:experiments_list) || []
    end

    def self.add_to_experiments_list(slug)
      set(:experiments_list, (experiments_list << slug).to_json)
    end

    def self.create_metrics(experiment)
      set(:metric_slugs, experiment.metric_slugs, experiment: experiment)
      experiment.metric_slugs.each do |metric_slug|
        if !experiment.variant_slugs.nil?
          experiment.variant_slugs.each do |variant_slug|
            Metric.create(metric_slug, experiment.slug, variant_slug)
          end
        else
          Metric.create(metric_slug, experiment.slug)
        end
      end
    end

    def self.create_variants(experiment)
      if !experiment.variant_slugs.nil?
        set(:variant_slugs, experiment.variant_slugs, experiment: experiment)
      end
    end

  end
end
module Absurdity
  class Datastore
    PARSE_AS_JSON = [
      :metrics_list,
      :variants_list,
      :experiments_list
    ]

    def self.save(object)
      klass = object.class
      if klass == Absurdity::Experiment
        save_experiment(object)
      elsif klass == Absurdity::Metric
        save_metric(object)
      elsif klass == Absurdity::Variant
        save_variant(object)
      end
    end

    def self.all(klass)
      if klass == Absurdity::Experiment
        all_experiments
      elsif klass == Absurdity::Metric
        all_metrics
      elsif klass == Absurdity::Variant
        all_variants
      end
    end

    def self.find(klass, options)
      if klass == Absurdity::Experiment
        find_experiment(options[:slug])
      elsif klass == Absurdity::Metric
        find_metric(options[:slug], options[:experiment_slug], options[:variant_slug])
      elsif klass == Absurdity::Variant
        find_variant(options[:identity_id], options[:experiment_slug])
      end
    end

    private

    def self.redis
      Config.instance.redis
    end


    # FINDERS

    def self.find_experiment(experiment_slug)
      return nil unless slug = experiments_list.find { |e| e == experiment_slug }
      experiment = Experiment.new(slug)
      experiment.attributes[:metrics_list]  = get(:metrics_list, experiment: experiment)
      experiment.attributes[:variants_list] = get(:variants_list, experiment: experiment)
      experiment.attributes[:completed]     = get(:completed, experiment: experiment)
      experiment
    end

    def self.find_metric(metric_slug, experiment_slug, variant_slug)
      experiment = find_experiment(experiment_slug)
      return nil unless experiment && experiment.metrics_list.find { |sl| sl == metric_slug }
      metric = Metric.new(metric_slug, experiment_slug, variant_slug)
      metric.instance_variable_set(:@count, metric_count(metric))
      metric
    end

    def self.find_variant(identity_id, experiment_slug)
      experiment = find_experiment(experiment_slug)
      return nil unless slug = get(variant_key(identity_id), experiment: experiment)
      Variant.new(slug, experiment_slug, identity_id)
    end

    def self.all_experiments
      experiments_list.map { |exp| find_experiment(exp) }
    end


    # SAVERS

    def self.save_metric(metric)
      set(metric_key(metric), metric.count.to_i, experiment: find_experiment(metric.experiment_slug))
    end

    def self.save_experiment(experiment)
      unless find_experiment(experiment.slug)
        add_to_experiments_list(experiment.slug)
        create_variants(experiment)
        create_metrics(experiment)
      end
      mark_completed(experiment) if experiment.completed
    end

    def self.save_variant(variant)
      set(variant_key(variant.identity_id), variant.slug, experiment: find_experiment(variant.experiment_slug))
    end

    def self.get(key, options={})
      if experiment = options[:experiment]
        store_key = "experiments:#{experiment.slug}:#{key}"
      else
        store_key = "experiments:#{key}"
      end
      string = redis.get(store_key)
      if string.to_i.to_s == string
        string.to_i
      elsif PARSE_AS_JSON.include?(key)
        string && JSON.parse(string).map { |v| v.to_sym }
      else
        string && string.to_sym
      end
    end

    def self.set(key, value, options={})
      if experiment = options[:experiment]
        store_key = "experiments:#{experiment.slug}:#{key}"
      else
        store_key = "experiments:#{key}"
      end
      redis.set(store_key, value)
    end

    def self.metric_count(metric)
      experiment = find_experiment(metric.experiment_slug)
      get(metric_key(metric), experiment: experiment).to_i
    end

    def self.metric_key(metric)
      key = metric.variant_slug ? "#{metric.variant_slug}" : ""
      key += ":#{metric.slug}:count"
      key
    end

    def self.variant_key(identity_id)
      "identity_id:#{identity_id}:variant"
    end

    def self.experiments_list
      get(:experiments_list) || []
    end

    def self.add_to_experiments_list(slug)
      set(:experiments_list, (experiments_list << slug).to_json)
    end

    def self.create_metrics(experiment)
      set(:metrics_list, experiment.metrics_list.to_json, experiment: experiment)
      experiment.metrics_list.each do |metric_slug|
        if experiment.variants?
          experiment.variants_list.each do |variant_slug|
            Metric.create(metric_slug, experiment.slug, variant_slug)
          end
        else
          Metric.create(metric_slug, experiment.slug)
        end
      end
    end

    def self.create_variants(experiment)
      if !experiment.variants_list.nil?
        set(:variants_list, experiment.variants_list.to_json, experiment: experiment)
      end
    end

    def self.mark_completed(experiment)
      set(:completed, experiment.completed, experiment: experiment)
    end

    def self.logger
      Config.instance.logger
    end

  end
end
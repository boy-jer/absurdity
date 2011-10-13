module Absurdity
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      Absurdity::Config.instance.logger = ::Rails.logger
      # load ::Rails.root.join("absurdity/experiments.rb")
      experiments_to_create = YAML.load_file("absurdity/experiments.yml")[:experiments]
      experiments_to_create.each do |experiment_slug, values|
        metrics_list = values[:metrics]
        variants_list = values[:variants]
        experiment = Absurdity.new_experiment(experiment_slug, metrics_list, variants_list)
        Absurdity.complete(experiment_slug, values[:completed]) if values[:completed] && !experiment.completed
      end
    end
  end
end
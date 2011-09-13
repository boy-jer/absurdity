class AbsurditiesController < ApplicationController
  layout "absurdities"

  def index
    @experiments = Absurdity::Experiment.all
    p @experiments.first.metrics
    p @experiments.first.variants
    # @experiments.first.metrics.each do |metric|
    #   @experiments.first.variants
    #   Absurdity::Metric.find(metric)
    # end
  end

end
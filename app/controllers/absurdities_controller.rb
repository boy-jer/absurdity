class AbsurditiesController < ApplicationController
  layout "absurdities"

  def index
    @experiments = Absurdity::Experiment.all
  end

end
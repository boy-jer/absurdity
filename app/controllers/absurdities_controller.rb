class AbsurditiesController < ApplicationController
  helper :absurdity
  layout "absurdities"

  def index
    @report = Absurdity.report
  end

  def show
    @report = Experiment.find(params[:id]).report
  end

end
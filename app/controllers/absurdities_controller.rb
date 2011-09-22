class AbsurditiesController < ApplicationController
  helper :absurdity
  layout "absurdities"

  def index
    @reports = Absurdity.reports
  end

  def show
    @report = Absurdity::Experiment.find(params[:id].to_sym).report
  end

  def create
    Absurdity.track!(params[:metric], params[:experiment], params[:identity_id])
    render nothing: true
  end

end
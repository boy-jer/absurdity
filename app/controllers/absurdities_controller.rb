class AbsurditiesController < ApplicationController
  layout "absurdities"

  def index
    @report = Absurdity.report
  end

end
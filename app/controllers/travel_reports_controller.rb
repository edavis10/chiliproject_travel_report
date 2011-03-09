class TravelReportsController < ApplicationController
  unloadable
  
  before_filter :require_login
  before_filter :authorize_global

  def index
    if params[:date_from].present?
      @date_from = params[:date_from].to_s.to_date
    end

    if params[:date_to].present?
      @date_to = params[:date_to].to_s.to_date
    end

    @travel_approved = Issue.traveling_between(@date_from, @date_to) #.approved_for_travel
    @travel_denied = Issue.traveling_between(@date_from, @date_to) #.approved_for_travel
  end

end

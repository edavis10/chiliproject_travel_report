class TravelReportsController < ApplicationController
  unloadable
  
  before_filter :require_login
  before_filter :authorize_global

  def index
    begin
      if params[:date_from].present?
        @date_from = params[:date_from].to_s.to_date
      end

      if params[:date_to].present?
        @date_to = params[:date_to].to_s.to_date
      end

    rescue # to_date can throw several errors, NoMethodError is common
      @date_from = Date.today
      @date_to = Date.today
    end

    @user_ids = params[:user_ids] || []
    @travel_approved = Issue.visible.traveling_between(@date_from, @date_to).approved_for_travel.travel_report_authored_by(@user_ids)
    @travel_denied = Issue.visible.traveling_between(@date_from, @date_to).denied_for_travel.travel_report_authored_by(@user_ids)

  end

end

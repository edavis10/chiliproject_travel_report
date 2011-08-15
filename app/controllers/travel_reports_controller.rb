class TravelReportsController < ApplicationController
  unloadable
  
  before_filter :require_login
  before_filter :authorize_global

  helper :custom_fields
  include CustomFieldsHelper
  
  def index
    begin
      if params[:date_from].present?
        @date_from = params[:date_from].to_s.to_date
      end

      if params[:date_to].present?
        @date_to = params[:date_to].to_s.to_date
      end

    rescue # to_date can throw several errors, NoMethodError is common
    end

    @date_from ||= Date.today
    @date_to ||= Date.today

    @user_ids = params[:user_ids] || []
    @travel_approved = Issue.visible.traveling_between(@date_from, @date_to).approved_for_travel.travel_report_authored_by(@user_ids)
    @travel_denied = Issue.visible.traveling_between(@date_from, @date_to).denied_for_travel.travel_report_authored_by(@user_ids)

    respond_to do |format|
      format.html { }
      format.csv { send_data(travel_report_to_csv(@travel_approved, @travel_denied), :type => 'text/csv; header=present', :filename => 'travel-report.csv') }

    end
  end

  private

  def travel_report_to_csv(approved, denied)
    decimal_separator = l(:general_csv_decimal_separator)
    export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
      headers = [
                 "#",
                 l(:travel_report_status),
                 l(:field_status),
                 l(:field_project),
                 l(:field_tracker),
                 l(:field_subject)
                ]

      custom_fields = IssueCustomField.all
      custom_fields.each {|f| headers << f.name}

      csv << headers

      approved.each do |issue|
        fields = [
                issue.id,
                l(:travel_report_travel_approved),
                issue.status.name,
                issue.project.name,
                issue.tracker.name,
                issue.subject
               ]
        custom_fields.each {|f| fields << show_value(issue.custom_value_for(f)) }

        csv << fields
      end

      denied.each do |issue|
        fields = [
                  issue.id,
                  l(:travel_report_travel_denied),
                  issue.status.name,
                  issue.project.name,
                  issue.tracker.name,
                  issue.subject
                 ]
        custom_fields.each {|f| fields << show_value(issue.custom_value_for(f)) }

        csv << fields
      end
    end

    export
  end
  
end

require 'test_helper'

class TravelReportTest < ActionController::IntegrationTest

  def setup
    generate_custom_fields
    generate_issue_statuses
    User.current = nil
  end

  context "visiting the report page" do
    context "permissions" do
      should "allow admins" do
        @admin = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
        login_as(@admin.login, 'existing')

        visit_travel_report_success
      end
      
      should "allow any user with the Travel Reports permission" do
        @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
        @project = Project.generate!
        @role = Role.generate!(:permissions => [:travel_reports])
        User.add_to_project(@user, @project, @role)
        
        login_as(@user.login, 'existing')

        visit_travel_report_success

      end
      
      should "deny users without the Travel Reports permission" do
        @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
        login_as(@user.login, 'existing')

        visit_travel_report_failure
      end
      
      should "deny anonymous users" do
        visit_travel_report_failure
      end
      
    end

    should "show a form with a date range to run reports" do
      @admin = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
      login_as(@admin.login, 'existing')

      visit_travel_report_success

      assert_select "#travel-report-form form" do
        assert_select "input#date_from"
        assert_select "input#date_to"
      end
      
    end
    
  end

  context "running travel reports" do
    context "permissions" do
      should "allow admins"
      should "allow any user with the Travel Reports permission"
      should "deny users without the Travel Reports permission"
      should "deny anonymous users"
    end

    should "submit forms with a GET request"
    should "find issues that are travelling within the form date range"
    should "show approved travel requests in one column"
    should "show denied travel requests in one column"
  end
end


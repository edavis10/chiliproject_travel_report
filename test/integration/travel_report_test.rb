require 'test_helper'

class TravelReportTest < ActionController::IntegrationTest

  def setup
    User.current = nil
    configure_plugin
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
    setup do
      @user = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
      @project = Project.generate!(:trackers => [standard_tracker])
      @project.issue_custom_fields = IssueCustomField.all
      @project.reload
      @role = Role.generate!(:permissions => [:travel_reports, :view_issues])
      User.add_to_project(@user, @project, @role)

      @issue_inside = Issue.generate_to_travel(@project, standard_tracker, '2011-02-02', '2011-02-07')
      @issue_on_start = Issue.generate_to_travel(@project, standard_tracker, '2011-01-01', '2011-02-07')
      @issue_on_end = Issue.generate_to_travel(@project, standard_tracker, '2011-12-31', '2012-01-07')
      @issue_wrap_into_start = Issue.generate_to_travel(@project, standard_tracker, '2010-12-31', '2011-01-01')
      @issue_wrap_off_of_end = Issue.generate_to_travel(@project, standard_tracker, '2011-12-31', '2012-01-01')
      
      @issue_before_start = Issue.generate_to_travel(@project, standard_tracker, '2010-12-31', '2010-12-31')
      @issue_after_end = Issue.generate_to_travel(@project, standard_tracker, '2012-01-01', '2012-01-01')
      login_as(@user.login, 'existing')

      visit_travel_report_success
    end
    
    should "submit forms with a GET request" do
      assert_select "#travel-report-form form[method=get]", :count => 1
    end
    
    should "find issues that are travelling within the form date range" do
      fill_in "date_from", :with => '2011-01-01'
      fill_in "date_to", :with => '2011-12-31'
      click_button 'Apply'

      assert_response :success

      assert_select "#travel-report" do
        assert_select "li", :text => /#{@issue_inside.subject}/
        assert_select "li", :text => /#{@issue_on_start.subject}/
        assert_select "li", :text => /#{@issue_on_end.subject}/
        assert_select "li", :text => /#{@issue_wrap_into_start.subject}/
        assert_select "li", :text => /#{@issue_wrap_off_of_end.subject}/

        assert_select "li", :text => /#{@issue_before_start.subject}/, :count => 0
        assert_select "li", :text => /#{@issue_after_end.subject}/, :count => 0
      end
      
    end
    
    should "show approved travel requests in one column"
    should "show denied travel requests in one column"
  end
end


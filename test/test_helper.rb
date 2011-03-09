# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

require "webrat"

Webrat.configure do |config|
  config.mode = :rails
end

def User.add_to_project(user, project, role)
  Member.generate!(:principal => user, :project => project, :roles => [role])
end

module RedmineWebratHelper
  def login_as(user="existing", password="existing")
    visit "/login"
    fill_in 'Login', :with => user
    fill_in 'Password', :with => password
    click_button 'login'
    assert_response :success
    assert User.current.logged?
  end

  def visit_project(project)
    visit '/'
    assert_response :success

    click_link 'Projects'
    assert_response :success

    click_link project.name
    assert_response :success
  end

  def visit_issue_page(issue)
    visit '/issues/' + issue.id.to_s
  end

  def visit_issue_bulk_edit_page(issues)
    visit url_for(:controller => 'issues', :action => 'bulk_edit', :ids => issues.collect(&:id))
  end

  # Cleanup current_url to remove the host; sometimes it's present, sometimes it's not
  def current_path
    return nil if current_url.nil?
    return current_url.gsub("http://www.example.com","")
  end

end

module TravelReportTestHelper
  def visit_plugin_configuration_panel
    visit '/'
    click_link 'Administration'
    assert_response :success

    click_link 'Plugins'
    assert_response :success

    click_link 'Configure'
    assert_response :success
  end

  def visit_travel_report_success
    visit '/'
    click_link 'Travel Report'
    assert_response :success
  end
  
  def visit_travel_report_failure
    visit '/'
    assert_select 'a', :text => /travel report/i, :count => 0

    visit '/travel_reports' # Direct url
    if User.current.logged?
      assert_response :forbidden
    else
      assert current_path.match(/login/i)
    end
    
  end

  def standard_tracker
    @tracker ||= Tracker.generate!
  end

  def generate_custom_fields
    @depart_custom_field = IssueCustomField.generate!(:name => 'Depart', :field_format => 'date', :trackers => [standard_tracker])
    @return_custom_field = IssueCustomField.generate!(:name => 'Return', :field_format => 'date', :trackers => [standard_tracker])
  end

  def generate_issue_statuses
    IssueStatus.generate!(:name => 'Open')
    IssueStatus.generate!(:name => 'Approved')
    IssueStatus.generate!(:name => 'Denied')
    IssueStatus.generate!(:name => 'Approved with change')
    IssueStatus.generate!(:name => 'Denied until later')
  end
  
end

def Issue.generate_to_travel(project, tracker, status, from, to)
  issue = Issue.generate_for_project!(project, :tracker => tracker, :status => status)
  issue.custom_field_values = {
    Setting.plugin_chiliproject_travel_report['depart_custom_field_id'] => from,
    Setting.plugin_chiliproject_travel_report['return_custom_field_id'] => to
  }
  issue.save!
  issue.reload
  
end

class ActionController::IntegrationTest
  include RedmineWebratHelper
  include TravelReportTestHelper
end

class ActiveSupport::TestCase
  def assert_forbidden
    assert_response :forbidden
    assert_template 'common/403'
  end

  def configure_plugin(configuration_change={})
    generate_custom_fields
    generate_issue_statuses
    Setting.plugin_chiliproject_travel_report = {
      'depart_custom_field_id' => @depart_custom_field.id.to_s,
      'return_custom_field_id' => @return_custom_field.id.to_s,
      'approved_issue_status_ids' => [IssueStatus.find_by_name('Approved'),
                                      IssueStatus.find_by_name('Approved with change')].collect(&:id).collect(&:to_s),
      'denied_issue_status_ids' => [IssueStatus.find_by_name('Denied'),
                                    IssueStatus.find_by_name('Denied until later')].collect(&:id).collect(&:to_s)
    }.merge(configuration_change)
  end

  def reconfigure_plugin(configuration_change)
    Settings['plugin_TODO'] = Setting['plugin_TODO'].merge(configuration_change)
  end
end

require 'test_helper'

class ConfigurationTest < ActionController::IntegrationTest

  def setup
    generate_custom_fields
    generate_issue_statuses
    @admin = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
    login_as(@admin.login, 'existing')
  end
  
  should "have a configuration page to store settings" do
    visit_plugin_configuration_panel
  end

  should "allow configuring the date fields on issues for departure and return dates" do
    visit_plugin_configuration_panel

    select "Depart", :from => "Departure custom field"
    select "Return", :from => "Return custom field"
    click_button "Apply"
    assert_response :success

    assert_equal @depart_custom_field.id, Setting.plugin_chiliproject_travel_report['depart_custom_field_id'].to_i
    assert_equal @return_custom_field.id, Setting.plugin_chiliproject_travel_report['return_custom_field_id'].to_i
  end

  should "allow configuring the issue status fields for Travel Approved" do
    visit_plugin_configuration_panel

    select "Approved", :from => "Approved statuses"
    select "Approved with change", :from => "Approved statuses"
    click_button "Apply"
    assert_response :success

    approved_ids = Setting.plugin_chiliproject_travel_report['approved_issue_status_ids']
    assert approved_ids.present?
    assert approved_ids.include?(IssueStatus.find_by_name('Approved').id.to_s)
    assert approved_ids.include?(IssueStatus.find_by_name('Approved with change').id.to_s)
  end

  should "allow configuring the issue status fields for Travel Denied" do
    visit_plugin_configuration_panel

    select "Denied", :from => "Denied statuses"
    select "Denied until later", :from => "Denied statuses"
    click_button "Apply"
    assert_response :success

    approved_ids = Setting.plugin_chiliproject_travel_report['denied_issue_status_ids']
    assert approved_ids.present?
    assert approved_ids.include?(IssueStatus.find_by_name('Denied').id.to_s)
    assert approved_ids.include?(IssueStatus.find_by_name('Denied until later').id.to_s)
  end
end


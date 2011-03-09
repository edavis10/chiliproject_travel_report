require 'test_helper'

class ConfigurationTest < ActionController::IntegrationTest

  def setup
    @depart_custom_field = IssueCustomField.generate!(:name => 'Depart', :field_format => 'date')
    @return_custom_field = IssueCustomField.generate!(:name => 'Return', :field_format => 'date')

    @admin = User.generate!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing', :admin => true)
    login_as(@admin.login, 'existing')
  end
  
  should "have a configuration page to store settings" do
    visit '/'
    click_link 'Administration'
    assert_response :success

    click_link 'Plugins'
    assert_response :success

    click_link 'Configure'
    assert_response :success
  end
  

  should "allow configuring the date fields on issues for departure and return dates" do
    visit '/'
    click_link 'Administration'
    assert_response :success

    click_link 'Plugins'
    assert_response :success

    click_link 'Configure'
    assert_response :success

    select "Depart", :from => "Departure custom field"
    select "Return", :from => "Return custom field"
    click_button "Apply"
    assert_response :success

    assert_equal @depart_custom_field.id, Setting.plugin_chiliproject_travel_report['depart_custom_field_id'].to_i
    assert_equal @return_custom_field.id, Setting.plugin_chiliproject_travel_report['return_custom_field_id'].to_i
  end
  
end


require 'test_helper'

class ConfigurationTest < ActionController::IntegrationTest

  def setup
    generate_custom_fields
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
  
end


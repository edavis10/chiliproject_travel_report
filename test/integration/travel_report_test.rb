require 'test_helper'

class TravelReportTest < ActionController::IntegrationTest

  def setup
  end

  context "visiting the report page" do
    context "permissions" do
      should "allow admins"
      should "allow any user with the Travel Reports permission"
      should "deny users without the Travel Reports permission"
      should "deny anonymous users"
    end

    should "show a form with a date range to run reports"
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


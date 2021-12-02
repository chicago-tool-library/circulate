require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:admin_user)
    sign_in @user
  end

  test "should get index" do
    get admin_dashboard_url
    assert_response :success
  end
end

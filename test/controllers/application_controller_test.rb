require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = create(:user)
    @admin_user = create(:admin_user)
  end

  test "should redirect to member loans after login" do
    sign_in(@user)
    post user_session_url
    assert_redirected_to account_home_path
  end

  test "should redirect to admin dashboard after login" do
    sign_in(@admin_user)
    post user_session_url
    assert_redirected_to admin_dashboard_path
  end
end
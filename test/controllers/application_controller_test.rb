require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = create(:user)
    @admin_user = create(:admin_user)
  end

  test "should redirect to member loans after login if there is no referer" do
    sign_in(@user)
    post user_session_url
    assert_redirected_to member_loans_path
  end

  test "should redirect to admin dashboard after login if there is no referer" do
    sign_in(@admin_user)
    post user_session_url
    assert_redirected_to admin_dashboard_path
  end

  test "should redirect to previous page for admin after login if there is a referer" do
    # @request.env['HTTP_REFERER'] = 'http://www.example.com/items'
    sign_in(@admin_user)
    post user_session_path, headers: { "referer": "http://www.example.com/items" }
    assert_redirected_to items_path
  end

  test "should redirect to previous page for member after login if there is a referer" do
    @request.env['HTTP_REFERER'] = 'http://www.example.com/items'
    sign_in(@user)
    post user_session_path
    assert_redirected_to items_path
  end
end
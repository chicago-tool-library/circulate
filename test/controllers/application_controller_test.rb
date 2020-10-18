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
    get new_user_session_path, headers: {referer: "http://www.example.com/original-page"}
    post user_session_path, params: {user: {email: @admin_user.email, password: "password"}}
    assert_redirected_to "http://www.example.com/original-page"
  end

  test "should redirect to previous page for member after login if there is a referer" do
    get new_user_session_path, headers: {referer: "http://www.example.com/items/1"}
    post user_session_path, params: {user: {email: @user.email, password: "password"}}
    assert_redirected_to "http://www.example.com/items/1"
  end

  test "should not redirect to previous page for member after login if referer is not of the same domain" do
    get new_user_session_path, headers: {referer: "http://www.foreigndomain.com/circulate"}
    post user_session_path, params: {user: {email: @user.email, password: "password"}}
    assert_redirected_to member_loans_path
  end

  test "ignores a poorly formed referer" do
    get new_user_session_path, headers: {referer: "not a valid referer"}
  end
end
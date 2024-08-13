require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = create(:user)
    @admin_user = create(:admin_user)
  end

  test "should redirect to member loans after login if there is no referer" do
    sign_in(@user)
    post user_session_url
    assert_redirected_to account_home_path
  end

  test "should redirect to admin dashboard after login if there is no referer" do
    sign_in(@admin_user)
    post user_session_url
    assert_redirected_to admin_dashboard_path
  end

  test "should redirect to previous page for admin after login if there is a referer" do
    get new_user_session_path, headers: {referer: "http://example.com/original-page"}
    post user_session_path, params: {user: {email: @admin_user.email, password: "password"}}
    assert_redirected_to "http://example.com/original-page"
  end

  test "should redirect to previous page for member after login if there is a referer" do
    get new_user_session_path, headers: {referer: "http://example.com/items/1"}
    post user_session_path, params: {user: {email: @user.email, password: "password"}}
    assert_redirected_to "http://example.com/items/1"
  end

  test "should not redirect to previous page for member after login if referer is not of the same domain" do
    get new_user_session_path, headers: {referer: "http://www.foreigndomain.com/circulate"}
    post user_session_path, params: {user: {email: @user.email, password: "password"}}
    assert_redirected_to account_home_path
  end

  test "ignores a poorly formed referer" do
    assert_nothing_raised {
      get new_user_session_path, headers: {referer: "not a valid referer"}
    }
  end
end

# This is a lot of code to work around that I couldn't find a nice way to
# stub `protect_against_forgery?` for any instance of a subclass of
# ApplicationController. The value of this method is cached, so it's not
# possible to simply change the config value and have it take affect.
#
# In this case we're using a specific subclass to verify the desired behavior.
class ApplicationControllerCSRFTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    class Users::SessionsController # standard:disable Lint/ConstantDefinitionInBlock
      alias_method :original_protect_against_forgery?, :protect_against_forgery?
      def protect_against_forgery?
        true
      end
    end
  end

  teardown do
    class Users::SessionsController # standard:disable Lint/ConstantDefinitionInBlock
      alias_method :protect_against_forgery?, :original_protect_against_forgery?
      remove_method :original_protect_against_forgery?
    end
  end

  test "handles an invalid_authenticity_token" do
    post user_session_path, params: {user: {email: @user.email, password: "password"}}, headers: {referer: "http://example.com/users/sessions/new"}

    assert_response :redirect
    assert_equal "http://example.com/users/sessions/new", response.location
    assert_equal "There was an issue with your submission, please try again.", flash[:error]
  end
end

require "test_helper"

module Account
  class PasswordsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      @member = create(:member, user: @user)

      sign_in @user

      @user_password_edit = {
        current_password: @user.password,
        password: "new_password",
        password_confirmation: "new_password"
      }
    end

    test "member views password" do
      get edit_account_password_url(@member.id)
      assert_response :success
    end

    test "member updates password" do
      put account_password_url, params: {user: @user_password_edit}
      assert_redirected_to account_member_url
    end

    test "member enters mismatched password" do
      @user_password_edit[:password_confirmation] = "mismatched"
      put account_password_url, params: {user: @user_password_edit}
      assert_redirected_to edit_account_password_url
      assert @user.errors.full_messages.include?("Password confirmation doesn't match Password")
    end

    test "member enters short password" do
      @user_password_edit[:password] = "short"
      @user_password_edit[:password_confirmation] = "short"
      put account_password_url, params: {user: @user_password_edit}
      assert_redirected_to edit_account_password_url
      assert @user.errors.full_messages.include?("Password is too short (minimum is 6 characters)")
    end

    test "member enters incorrect current password" do
      @user_password_edit[:current_password] = "wrong_password"
      put account_password_url, params: {user: @user_password_edit}
      assert_redirected_to edit_account_password_url
      assert @user.errors.full_messages.include?("Current password is invalid")
    end
  end
end

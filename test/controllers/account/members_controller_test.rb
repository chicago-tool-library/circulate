require "test_helper"

module Account
  class MembersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @member = create(:verified_member_with_membership)
      @user = create(:user, member: @member)
      sign_in @user
    end

    test "redirects logged out users to sign in page" do
      sign_out @user
      get account_member_url
      assert_redirected_to new_user_session_path
    end

    test "member views profile" do
      get account_member_url
      assert_response :success
    end

    test "member edits profile" do
      get edit_account_member_url
      assert_response :success
    end

    test "member updates profile" do
      patch account_member_url, params: {member: {full_name: "Updated Name"}}
      assert_redirected_to account_member_url
      assert_equal "Updated Name", @member.full_name
    end

    test "member updates email" do
      patch account_member_url, params: {member: {email: "new.email@example.com"}}

      sent_email = ActionMailer::Base.deliveries.first
      assert_equal ["new.email@example.com"], sent_email.to
      assert_equal "Confirmation instructions", sent_email.subject

      assert_redirected_to account_member_url
    end

    test "member update redirects to edit when provided invalid params" do
      patch account_member_url, params: {member: {full_name: nil}}
      assert_template :edit
    end
  end
end

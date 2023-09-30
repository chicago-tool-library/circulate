# frozen_string_literal: true

require "test_helper"

module Account
  class MembersControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @member = create(:verified_member_with_membership)
      @user = create(:user, member: @member)
      sign_in @user
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
      patch account_member_url, params: { member: { full_name: "Updated Name" } }
      assert_redirected_to account_member_url
      assert_equal "Updated Name", @member.full_name
    end

    test "member update redirects to edit when provided invalid params" do
      patch account_member_url, params: { member: { full_name: nil } }
      assert_template :edit
    end
  end
end

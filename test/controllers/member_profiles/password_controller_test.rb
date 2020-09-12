require 'test_helper'

class MemberProfiles::PasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:user)
    @member = create(:member, user: @user)

    sign_in @user
  end

  test "member views password" do
    get edit_member_profiles_password_url(@member.id)
    assert_response :success
  end
end

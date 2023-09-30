# frozen_string_literal: true

require "test_helper"

class VerificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:admin_user)
    sign_in @user
  end

  test "views the verification page" do
    @member = create(:complete_member)

    get edit_admin_member_verification_url(@member)

    assert_response :success
  end

  test "verifies a member" do
    @member = create(:complete_member)

    put admin_member_verification_url(@member), params: {
      admin_verification: {
        id_kind: Member.id_kinds.keys.first,
        address_verified: "1"
      }
    }

    # puts response.body.inspect
    assert_response :redirect

    @member.reload
    assert_equal "drivers_license", @member.id_kind
    assert @member.address_verified
    assert_equal "verified", @member.status
    assert @member.number
  end
end

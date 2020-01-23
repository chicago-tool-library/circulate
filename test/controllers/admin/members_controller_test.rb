require "test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @member = create(:member)
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get admin_members_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_member_url
    assert_response :success
  end

  test "should create member" do
    assert_difference("Member.count") do
      post admin_members_url, params: {
        member: {
          address_verified: @member.address_verified,
          other_id_kind: @member.other_id_kind,
          custom_pronoun: @member.custom_pronoun,
          email: @member.email,
          full_name: @member.full_name,
          id_kind: @member.id_kind,
          notes: @member.notes,
          phone_number: @member.phone_number,
          preferred_name: @member.preferred_name,
          pronoun: @member.pronoun,
          postal_code: "60606",
          address1: @member.address1,
        },
      }
    end

    assert_redirected_to admin_member_url(Member.last)
  end

  test "should show member" do
    get admin_member_url(@member)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_member_url(@member)
    assert_response :success
  end

  test "should update member" do
    patch admin_member_url(@member), params: {member: {address_verified: @member.address_verified, other_id_kind: @member.other_id_kind, custom_pronoun: @member.custom_pronoun, email: @member.email, full_name: @member.full_name, id_kind: @member.id_kind, notes: @member.notes, phone_number: @member.phone_number, preferred_name: @member.preferred_name, pronoun: @member.pronoun, postal_code: "60606"}}
    assert_redirected_to admin_member_url(@member)
  end
end

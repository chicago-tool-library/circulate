require 'test_helper'

class MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = members(:complete)
  end

  test "should get index" do
    get members_url
    assert_response :success
  end

  test "should get new" do
    get new_member_url
    assert_response :success
  end

  test "should create member" do
    assert_difference('Member.count') do
      post members_url, params: { member: { address_verified: @member.address_verified, other_id_kind: @member.other_id_kind, custom_pronoun: @member.custom_pronoun, email: @member.email, full_name: @member.full_name, id_kind: @member.id_kind, id_number: @member.id_number, notes: @member.notes, phone_number: @member.phone_number, preferred_name: @member.preferred_name, pronoun: @member.pronoun } }
    end

    assert_redirected_to member_url(Member.last)
  end

  test "should show member" do
    get member_url(@member)
    assert_response :success
  end

  test "should get edit" do
    get edit_member_url(@member)
    assert_response :success
  end

  test "should update member" do
    patch member_url(@member), params: { member: { address_verified: @member.address_verified, other_id_kind: @member.other_id_kind, custom_pronoun: @member.custom_pronoun, email: @member.email, full_name: @member.full_name, id_kind: @member.id_kind, id_number: @member.id_number, notes: @member.notes, phone_number: @member.phone_number, preferred_name: @member.preferred_name, pronoun: @member.pronoun } }
    assert_redirected_to member_url(@member)
  end

  test "should destroy member" do
    assert_difference('Member.count', -1) do
      delete member_url(@member)
    end

    assert_redirected_to members_url
  end
end

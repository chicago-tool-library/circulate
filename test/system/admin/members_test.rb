require "application_system_test_case"

class Admin::MembersTest < ApplicationSystemTestCase
  include ActionView::Helpers::NumberHelper

  def setup
    @member = create(:verified_member_with_membership, :with_pronunciation)
    sign_in_as_admin
  end

  test "admin can view member's profile" do
    visit admin_member_url(@member)

    assert_content @member.full_name
    assert_content @member.email
    assert_content number_to_phone(@member.phone_number, pattern: /^(\d{0,3})(\d{0,3})(\d{0,4})/, delimiter: " ")&.strip
    assert_content @member.display_pronouns
    assert_content @member.number
    assert_content @member.pronunciation
  end

  test "admin can edit member's profile" do
    visit admin_member_url(@member)

    click_on "Edit Member"
    fill_in "Full name", with: "Updated Name"
    fill_in "Pronunciation", with: "əpˈdeɪtəd neɪm"
    find("label", text: "she/her").click # uncheck
    find("label", text: "he/him").click # check
    click_on "Update Member"

    assert_current_path admin_member_url(@member)
    assert_content "Updated Name"
    assert_content "əpˈdeɪtəd neɪm"
    assert_content "he/him"
    assert_no_content "she/her"
  end

  test "staff can lookup regardless of a member's overdue loans" do
    @user.update!(role: :staff)

    create(:overdue_loan, member: @member)

    visit admin_member_url(@member)

    assert_content "Lookup"
  end
end

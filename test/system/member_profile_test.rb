require "application_system_test_case"

class MemberProfileTest < ApplicationSystemTestCase
  def setup
    @member = create(:verified_member_with_membership, created_at: 1.year.ago)
    @user = create(:user, member: @member)
    login_as @user
  end

  def borrow_policy_code_name(borrow_policy)
    "#{borrow_policy.code}-Tools"
  end

  test "member can view profile" do
    visit account_member_url

    assert_content @member.full_name
    assert_content @member.number
  end

  test "a member can see their approval statuses for borrow policies that require approval" do
    no_approval_borrow_policy = create(:borrow_policy, requires_approval: false)
    requires_approval_borrow_policy = create(:borrow_policy, :requires_approval)

    approved = create(:borrow_policy_approval, :approved, member: @member)
    rejected = create(:borrow_policy_approval, :rejected, member: @member)
    requested = create(:borrow_policy_approval, :requested, member: @member)
    revoked = create(:borrow_policy_approval, :revoked, member: @member)

    visit account_member_url

    refute_content borrow_policy_code_name(no_approval_borrow_policy)
    assert_content(/#{borrow_policy_code_name(approved.borrow_policy)}:\s+Approved/)
    assert_content(/#{borrow_policy_code_name(rejected.borrow_policy)}:\s+Not approved/)
    assert_content(/#{borrow_policy_code_name(requested.borrow_policy)}:\s+Requested/)
    assert_content(/#{borrow_policy_code_name(revoked.borrow_policy)}:\s+No longer approved/)
    assert_content(/#{borrow_policy_code_name(requires_approval_borrow_policy)}:\s+Never Requested/)
  end

  test "a member can request approval for a borrow policy" do
    borrow_policy = create(:borrow_policy, :requires_approval)

    visit account_member_url

    assert_content(/#{borrow_policy_code_name(borrow_policy)}:\s+Never Requested/)

    assert_difference("BorrowPolicyApproval.count", 1) do
      click_on "Request approval"
      assert_text "Approval requested."
      assert_content(/#{borrow_policy_code_name(borrow_policy)}:\s+Requested/)
      refute_text "Request approval"
    end

    borrow_policy_approval = BorrowPolicyApproval.first!

    assert_equal borrow_policy, borrow_policy_approval.borrow_policy
    assert_equal @member, borrow_policy_approval.member
    assert_equal "requested", borrow_policy_approval.status
  end

  test "a new member cannot request approval for a borrow policy" do
    borrow_policy = create(:borrow_policy, :requires_approval)
    @member.update!(created_at: 1.day.ago)

    visit account_member_url

    assert_content(/#{borrow_policy_code_name(borrow_policy)}:\s+Never Requested/)
    refute_content "Request approval"
  end

  test "member can edit profile" do
    visit account_member_url
    click_on "Edit Member Profile"

    fill_in "Full name", with: "Updated Name"
    find("label", text: "she/her").click # uncheck
    find("label", text: "he/him").click # check
    click_on "Update Member"
    assert_content "Updated Name"
    assert_content "he/him"
    assert_no_content "she/her"
  end

  test "member sees validation errors on update failure" do
    visit account_member_url
    click_on "Edit Member Profile"

    fill_in "Full name", with: ""
    click_on "Update Member"
    assert_content "Please correct the errors below!"
    # Ensure that the error message for the correct field is displayed
    assert_equal "can't be blank", page.find("label", text: "Full name").sibling(".form-input-hint").text
  end
end

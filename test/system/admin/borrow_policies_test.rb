require "application_system_test_case"

class BorrowPoliciesTest < ApplicationSystemTestCase
  include AdminHelper

  setup do
    sign_in_as_admin
  end

  test "updating a borrow_policy" do
    audited_as_admin do
      @borrow_policy = create(:borrow_policy)
    end

    visit edit_admin_borrow_policy_url(@borrow_policy)

    fill_in "Name", with: "New Name"
    fill_in "Code", with: "N"
    fill_in "Description", with: "This is the description"
    fill_in "Loan length", with: "12"
    fill_in "Renewal limit", with: "3"
    fill_in "Renewal limit", with: "3"
    fill_in "Fine period", with: "2"
    first("label", text: "Requires approval").click # check
    click_on "Update Borrow policy"

    assert_text "Borrow policy was successfully updated"
  end

  test "viewing a borrow policy" do
    audited_as_admin do
      @borrow_policy = create(:borrow_policy, requires_approval: false)
    end

    visit admin_borrow_policy_path(@borrow_policy)

    assert_text "#{@borrow_policy.code} #{@borrow_policy.name}"
    assert_text "Duration\n#{@borrow_policy.duration}"
    assert_text "Fine\n#{@borrow_policy.fine}"
    assert_text "Fine Period\n#{@borrow_policy.fine_period}"
    assert_text "Uniquely Numbered\n#{@borrow_policy.uniquely_numbered}"
    assert_text "Consumable\n#{@borrow_policy.consumable}"
    assert_text "Default\n#{@borrow_policy.default}"
    assert_text "Requires Approval\n#{@borrow_policy.default}"
    assert_text "Edit"
  end

  test "viewing a borrow policy's approvals" do
    audited_as_admin do
      @borrow_policy = create(:borrow_policy, requires_approval: true)
    end

    bpa_ignored = create(:borrow_policy_approval, :approved)
    bpa_approved = create(:borrow_policy_approval, :approved, borrow_policy: @borrow_policy)
    bpa_rejected = create(:borrow_policy_approval, :rejected, borrow_policy: @borrow_policy)
    bpa_requested = create(:borrow_policy_approval, :requested, borrow_policy: @borrow_policy)
    bpa_revoked = create(:borrow_policy_approval, :revoked, borrow_policy: @borrow_policy)

    visit admin_borrow_policy_path(@borrow_policy)

    click_on "Manage Approvals"

    assert_current_path admin_borrow_policy_borrow_policy_approvals_path(@borrow_policy)

    refute_css("[href='#{admin_member_path(bpa_ignored.member)}']")

    assert_css("[href='#{admin_member_path(bpa_approved.member)}']")
    assert_css("[href='#{admin_member_path(bpa_rejected.member)}']")
    assert_css("[href='#{admin_member_path(bpa_requested.member)}']")
    assert_css("[href='#{admin_member_path(bpa_revoked.member)}']")

    assert_text bpa_approved.status.capitalize
    assert_text bpa_rejected.status.capitalize
    assert_text bpa_requested.status.capitalize
    assert_text bpa_revoked.status.capitalize
  end

  test "a borrow policy's approvals can be filtered" do
    audited_as_admin do
      @borrow_policy = create(:borrow_policy, requires_approval: true)
    end

    bpa_approved = create(:borrow_policy_approval, :approved, borrow_policy: @borrow_policy)
    bpa_rejected = create(:borrow_policy_approval, :rejected, borrow_policy: @borrow_policy)
    bpa_requested = create(:borrow_policy_approval, :requested, borrow_policy: @borrow_policy)
    bpa_revoked = create(:borrow_policy_approval, :revoked, borrow_policy: @borrow_policy)

    visit admin_borrow_policy_borrow_policy_approvals_path(@borrow_policy)

    select("Requested", from: "Status")
    click_on "Filter"

    assert_css("[href='#{admin_member_path(bpa_requested.member)}']")

    refute_css("[href='#{admin_member_path(bpa_approved.member)}']")
    refute_css("[href='#{admin_member_path(bpa_rejected.member)}']")
    refute_css("[href='#{admin_member_path(bpa_revoked.member)}']")
  end

  test "editing a borrow policy approval" do
    audited_as_admin do
      @borrow_policy = create(:borrow_policy, requires_approval: true)
    end

    bpa_requested = create(:borrow_policy_approval, :requested, borrow_policy: @borrow_policy)

    visit admin_borrow_policy_borrow_policy_approvals_path(@borrow_policy)

    click_on "Edit"

    assert_text "#{@borrow_policy.code} #{@borrow_policy.name}"
    assert_text preferred_or_default_name(bpa_requested.member)

    select("Approved", from: "Status")
    status_reason = "good member in good standing #{rand(100)}"
    fill_in "Status reason", with: status_reason
    click_on "Update"

    assert_text "Successfully updated Borrow Policy Approval"

    bpa_requested.reload
    assert_equal "approved", bpa_requested.status
    assert_equal status_reason, bpa_requested.status_reason
  end
end

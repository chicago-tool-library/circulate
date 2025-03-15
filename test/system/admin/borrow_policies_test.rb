require "application_system_test_case"

class BorrowPoliciesTest < ApplicationSystemTestCase
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
end

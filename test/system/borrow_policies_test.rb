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
end

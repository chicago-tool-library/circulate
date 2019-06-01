require "application_system_test_case"

class BorrowPoliciesTest < ApplicationSystemTestCase
  setup do
    @borrow_policy = borrow_policies(:one)
  end

  test "visiting the index" do
    visit borrow_policies_url
    assert_selector "h1", text: "Borrow Policies"
  end

  test "creating a Borrow policy" do
    visit borrow_policies_url
    click_on "New Borrow Policy"

    fill_in "Duration", with: @borrow_policy.duration
    fill_in "Fine cents", with: @borrow_policy.fine_cents
    fill_in "Fine period", with: @borrow_policy.fine_period
    fill_in "Name", with: @borrow_policy.name
    click_on "Create Borrow policy"

    assert_text "Borrow policy was successfully created"
    click_on "Back"
  end

  test "updating a Borrow policy" do
    visit borrow_policies_url
    click_on "Edit", match: :first

    fill_in "Duration", with: @borrow_policy.duration
    fill_in "Fine cents", with: @borrow_policy.fine_cents
    fill_in "Fine period", with: @borrow_policy.fine_period
    fill_in "Name", with: @borrow_policy.name
    click_on "Update Borrow policy"

    assert_text "Borrow policy was successfully updated"
    click_on "Back"
  end

  test "destroying a Borrow policy" do
    visit borrow_policies_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Borrow policy was successfully destroyed"
  end
end

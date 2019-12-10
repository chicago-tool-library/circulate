require "application_system_test_case"

class GiftMembershipsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "visiting the index" do
    visit admin_gift_memberships_url
    assert_selector "h1", text: "Gift Memberships"
  end

  test "creating a Gift membership" do
    visit admin_gift_memberships_url
    click_on "New Gift Membership"

    fill_in "Amount", with: "23"
    fill_in "Purchaser email", with: "created@place.biz"
    fill_in "Purchaser name", with: "created name"
    click_on "Create Gift membership"
    
    assert_text "Gift membership was successfully created"
    assert_text "$23.00"
    assert_text "created@place.biz"
    assert_text "created name"
  end

  test "updating a Gift membership" do
    create(:gift_membership)
    visit admin_gift_memberships_url
    click_on "Edit", match: :first

    fill_in "Amount", with: 45
    fill_in "Purchaser email", with: "changed@place.biz"
    fill_in "Purchaser name", with: "changed name"
    click_on "Update Gift membership"

    assert_text "Gift membership was successfully updated"
    assert_text "changed@place.biz"
    assert_text "changed name"
    assert_text "$45.00"
  end

  test "destroying a Gift membership" do
    create(:gift_membership)
    visit admin_gift_memberships_url
    click_on "Edit", match: :first
    page.accept_confirm do
      click_on "Destroy Gift Membership", match: :first
    end

    assert_text "Gift membership was successfully destroyed"
  end
end

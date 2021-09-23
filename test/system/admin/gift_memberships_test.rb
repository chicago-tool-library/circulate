require "application_system_test_case"

class GiftMembershipsTest < ApplicationSystemTestCase
  setup do
    ActionMailer::Base.deliveries.clear
    sign_in_as_admin
  end

  test "visiting the index" do
    visit admin_gift_memberships_url
    assert_selector "h1", text: "Gift Memberships"
  end

  test "creating a gift membership" do
    visit admin_gift_memberships_url
    click_on "New Gift Membership"

    fill_in "Amount", with: "23"
    fill_in "Purchaser email", with: "created@place.biz"
    fill_in "Purchaser name", with: "created name"
    fill_in "Recipient name", with: "recipient name"

    perform_enqueued_jobs do
      click_on "Create Gift membership"

      assert_text "Gift membership was successfully created", wait: 10
    end

    assert_text "$23.00"
    assert_text "created@place.biz"
    assert_text "created name"
    assert_text "recipient name"

    gift_membership = GiftMembership.last!

    assert_emails 1
    assert_delivered_email(to: "created@place.biz") do |html, text, attachments|
      assert_includes html, "You have successfully purchased a One Year Gift Membership to the #{ActsAsTenant.test_tenant.name}"
      assert_includes html, gift_membership.code.format

      assert_includes text, "You have successfully purchased a One Year Gift Membership to the #{ActsAsTenant.test_tenant.name}"
      assert_includes text, gift_membership.code.format

      assert_equal 1, attachments.size
      assert_equal "certificate.jpg", attachments.first.filename
    end
  end

  test "updating a gift membership" do
    gift_membership = create(:gift_membership)
    visit admin_gift_memberships_url
    click_on gift_membership.code.format, match: :first

    fill_in "Amount", with: 45
    fill_in "Purchaser email", with: "changed@place.biz"
    fill_in "Purchaser name", with: "changed name"
    click_on "Update Gift membership"

    assert_text "Gift membership was successfully updated"
    assert_text "changed@place.biz"
    assert_text "changed name"
    assert_text "$45.00"
  end

  test "destroying a gift membership" do
    gift_membership = create(:gift_membership)
    visit admin_gift_memberships_url
    click_on gift_membership.code.format, match: :first

    page.accept_confirm do
      click_on "Destroy Gift Membership", match: :first
    end

    assert_text "Gift membership was successfully destroyed"
  end

  test "double clicking create gift membership does not create multiple gift memberships" do
    visit admin_gift_memberships_url
    click_on "New Gift Membership"

    fill_in "Amount", with: "100"
    fill_in "Purchaser email", with: "repeat_test@place.biz"
    fill_in "Purchaser name", with: "repeat buyer"
    fill_in "Recipient name", with: "repeat recipient"

    perform_enqueued_jobs do
      find("button", text: "Create Gift membership").double_click

      assert_text "Gift membership was successfully created", wait: 10
    end

    assert_equal 1, GiftMembership.all.map(&:purchaser_email).count("repeat_test@place.biz")
  end
end

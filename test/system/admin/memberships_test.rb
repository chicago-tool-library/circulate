require "application_system_test_case"

class MembershipsTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "starts membership for pending member" do
    membership = create(:pending_membership)
    member = membership.member

    Time.use_zone "America/Chicago" do
      visit admin_member_url(member)

      assert_content "pending membership"
      click_on "Start Membership"

      refute_content "pending membership"
      assert_content "Membership started"

      membership.reload

      within ".account" do
        assert_content "Expires #{membership.ended_at.strftime("%b %-d, %Y")}"
      end

      click_on "Membership"
      assert_content membership.started_at.to_s(:long_date)
      assert_content membership.ended_at.to_s(:long_date)
    end
  end

  test "create active membership without a payment" do
    @member = create(:verified_member)

    visit admin_member_url(@member)

    click_on "Create Membership"
    first("label", text: "Create without payment").click
    click_on "Save Membership"

    within ".account" do
      assert_content "Expires"
    end

    click_on "Membership"
    assert_content "$0.00"
  end

  test "create pending membership without a payment" do
    @member = create(:verified_member)

    visit admin_member_url(@member)

    click_on "Create Membership"
    first("label", text: "Create without payment").click
    first("label", text: "Start this membership").click # uncheck

    click_on "Save Membership"

    within ".account" do
      assert_content "Pending"
    end

    click_on "Membership"
    assert_content "$0.00"
  end

  test "create active membership with payment" do
    @member = create(:verified_member)

    visit admin_member_url(@member)

    click_on "Create Membership"

    fill_in "This year's membership fee", with: "30"
    click_on "Save Membership"

    within ".account" do
      assert_content "Expires"
    end

    click_on "Membership"
    assert_content "$30.00"
  end

  test "create pending membership with payment" do
    @member = create(:verified_member)

    visit admin_member_url(@member)

    click_on "Create Membership"

    fill_in "This year's membership fee", with: "30"
    first("label", text: "Start this membership").click # uncheck
    click_on "Save Membership"

    within ".account" do
      assert_content "Pending"
    end

    click_on "Membership"
    assert_content "$30.00"
  end
end

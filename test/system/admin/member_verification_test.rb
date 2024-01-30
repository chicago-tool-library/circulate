require "application_system_test_case"

class MemberVerificationTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "verify pending member without membership" do
    @member = create(:member)

    visit admin_member_url(@member)

    assert_content "need to be verified"
    click_on "Verify Info"

    select "State", from: "Photo ID"
    first("label", text: "Address verified").click
    click_on "Verify Member"

    within ".member-stats.account" do
      @member.reload
      assert_content @member.number
    end

    within ".member-stats.account" do
      assert_content "Info verified"
    end

    assert_content "needs to start a membership"
    click_on "Create Membership"

    fill_in "This year's membership fee", with: "35"
    select "cash", from: "Payment source"

    click_on "Save Membership"

    assert_content "Expires"

    click_on "Membership"
    assert_content "$35.00"
  end

  test "verify pending member without membership using square" do
    @member = create(:member)

    visit admin_member_url(@member)

    assert_content "need to be verified"
    click_on "Verify Info"

    select "State", from: "Photo ID"
    first("label", text: "Address verified").click
    click_on "Verify Member"

    assert_content "Info verified"

    assert_content "needs to start a membership"
    click_on "Create Membership"

    fill_in "This year's membership fee", with: "43"
    select "square", from: "Payment source"

    click_on "Save Membership"
    assert_content "Expires"

    click_on "Membership"
    assert_content "$43.00"
  end

  test "verify pending member with a membership" do
    @member = create(:member)
    create(:membership, member: @member)

    visit admin_member_url(@member)

    assert_content "need to be verified"
    click_on "Verify Info"

    select "State", from: "Photo ID"
    first("label", text: "Address verified").click
    click_on "Verify Member"

    assert_content "Info verified"
  end

  test "create membership without a payment" do
    @member = create(:verified_member)

    visit admin_member_url(@member)

    click_on "Create Membership"
    first("label", text: "Create without payment").click
    click_on "Save Membership"

    assert_content "Expires"

    click_on "Membership"
    assert_content "$0.00"
  end
end

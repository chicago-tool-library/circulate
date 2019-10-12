require "application_system_test_case"

class MemberPaymentTest < ApplicationSystemTestCase
  def setup
    sign_in_as_admin
  end

  test "accepts a member payment" do
    @member = create(:active_member_with_membership)
    create(:fine_adjustment, member: @member, amount_cents: -1300)

    visit admin_member_url(@member)

    click_on "Record Payment"

    assert_content "Create a Payment"

    fill_in "Payment amount", with: "15"
    select "cash", from: "Payment source"

    click_on "Save Payment"

    assert_content "Balance: $0.00"

    click_on "Account History"

    assert_content "$-13.00 Fine"
    assert_content "$-2.00 Donation"
    assert_content "$15.00 Cash payment"
  end

  test "forgives a member's fines" do
    @member = create(:active_member_with_membership)
    create(:fine_adjustment, member: @member, amount_cents: -1000)

    visit admin_member_url(@member)

    click_on "Record Payment"

    assert_content "Create a Payment"

    fill_in "Payment amount", with: "8"
    select "forgiveness", from: "Payment source"

    click_on "Save Payment"

    assert_content "Balance: $-2.00"

    click_on "Account History"

    assert_content "$-10.00 Fine"
    assert_content "$8.00 Forgiven"
  end
end

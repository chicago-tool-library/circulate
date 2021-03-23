require "application_system_test_case"

class MemberHoldsTest < ApplicationSystemTestCase
  def setup
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    login_as @member.user
  end

  test "member can place a hold" do
    visit item_url(@item)
    click_button "Place a hold"

    assert_selector "button[disabled]", text: "Place a hold"
    assert_text "You placed a hold on this item."
  end

  test "member can place a hold multiple times when the borrow policy allows it" do
    @item.borrow_policy.update(uniquely_numbered: false)

    visit item_url(@item)

    click_button "Place a hold"
    assert_text "You currently have 1 hold placed."

    click_button "Place a hold"
    assert_text "You currently have 2 holds placed."
  end
end

require "application_system_test_case"

class MemberHoldsTest < ApplicationSystemTestCase
  def setup
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    @user = create(:user, member: @member)
    login_as @user
  end

  test "member can Place a hold" do
    visit item_url(@item)
    click_button "Place a hold"

    assert_selector "button[disabled]", text: "Place a hold"
    assert_text "You placed a hold on this item."
  end

  test "member can Place a hold multiple times when the borrow policy allows it" do
    @item.borrow_policy.update(code: "A")

    visit item_url(@item)

    click_button "Place a hold"
    assert_text "You currently have 1 hold placed."

    click_button "Place a hold"
    assert_text "You currently have 2 holds placed."
  end
end

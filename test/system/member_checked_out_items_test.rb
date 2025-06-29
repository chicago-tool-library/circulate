require "application_system_test_case"

class MemberCheckedOutItemsTest < ApplicationSystemTestCase
  setup do
    @member = create(:member, :with_user)

    login_as(@member.user)
  end

  test "member can see loans" do
    @loan = create(:loan, member: @member, item: create(:item, :with_image))

    visit account_loans_url

    within ".loan-list" do
      assert_text @loan.item.name
    end

    within ".details" do
      click_on @loan.item.name
    end
    assert_selector "h1", text: @loan.item.name
    assert_equal item_path(@loan.item), current_path
  end
end

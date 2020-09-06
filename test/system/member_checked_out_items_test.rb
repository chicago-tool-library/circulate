require "application_system_test_case"

class MemberCheckedOutItemsTest < ApplicationSystemTestCase
  setup do
    @user = create(:user)
    @member = create(:member, user: @user)

    login_as(@user)
  end

  test "member can see loans" do
    @loan = create(:loan, member: @member, item: create(:item, :with_image))

    visit member_loans_url

    within "#loans-table" do
      assert_text @loan.item.name
    end
  end
end

require "application_system_test_case"

class MemberCheckedOutItemsTest < ApplicationSystemTestCase
  test "member can see loans" do
    @member = create(:member)
    @loan = create(:loan, member: @member, item: create(:item, :with_image))

    visit member_loans_url

    within "#loans-table" do
      assert_text @loan.item.name
    end
  end
end

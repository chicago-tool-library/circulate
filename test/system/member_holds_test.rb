require "application_system_test_case"

class MemberHoldsTest < ApplicationSystemTestCase
  def setup
    @item = create(:item)
    @member = create(:verified_member_with_membership)
    @user = create(:user, member: @member)
    login_as @user
  end

  test "member can view Place a hold button" do
    visit item_url(@item)
    assert_link "Place a hold"
  end
end

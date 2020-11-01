require "test_helper"

class HoldsHelperTest < ActionView::TestCase
  setup do
    @member_1 = create(:member, full_name: "Member 1")
    @member_2 = create(:member, full_name: "Member 2")
    @member_3 = create(:member, full_name: "Member 3")
    @admin_user = create(:admin_user, member: @member_2)
    @user = create(:user, member: @member_1)
    @hold_1 = create(:hold, member: @member_1, creator: @user)
    @hold_2 = create(:hold, member: @member_2, creator: @admin_user, item: @hold_1.item)
  end

  test "should get the place in line for a hold" do
    assert_equal 1, place_in_line_for(@hold_1)
    assert_equal 2, place_in_line_for(@hold_2)
  end

  test "should get the place in line for active holds" do
    hold_3 = create(:hold, member: @member_3, creator: @admin_user, item: @hold_1.item)
    assert_equal 3, place_in_line_for(hold_3)
    @hold_2.ended_at = Time.current
    @hold_2.save!
    assert_equal 1, place_in_line_for(@hold_1)
    assert_equal 2, place_in_line_for(hold_3)
  end
end

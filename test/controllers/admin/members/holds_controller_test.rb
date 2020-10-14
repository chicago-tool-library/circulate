require "test_helper"

module Admin
  module Members
    class HoldsControllerTest < ActionController::TestCase
      setup do
        @member_1 = create(:member, full_name: 'Member 1')
        @member_2 = create(:member, full_name: 'Member 2')
        @admin_user = create(:admin_user, member: @member_2)
        @user = create(:user, member: @member_1)
        @hold_1 = create(:hold, member: @member_1, creator: @user)
        @hold_2 = create(:hold, member: @member_2, creator: @admin_user, item: @hold_1.item)
        # sign_in @user
      end

      test "should get the place in line for a hold" do
        assert_equal 1, @controller.helpers.place_in_line_for_hold(@hold_1)
        assert_equal 2, @controller.helpers.place_in_line_for_hold(@hold_2)
      end
    end
  end
end

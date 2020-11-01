require "test_helper"

module Admin
  module Members
    class HoldsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @member_1 = create(:member, full_name: 'Member 1')
        @admin_user = create(:admin_user, member: @member_2)
        sign_in @admin_user
        @user = create(:user, member: @member_1)
        @hold_1 = create(:hold, member: @member_1, creator: @user)
      end

      test "should lend a hold to a member" do
        assert_equal 1, @member_1.holds.active.includes(:item).length
        post lend_admin_member_hold_url(@member_1, @hold_1)
        assert_equal 0, @member_1.holds.active.includes(:item).length
        assert_redirected_to admin_member_holds_path(@hold_1.member)
      end
    end
  end
end

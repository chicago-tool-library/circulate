require "test_helper"

module Admin
  module Members
    class HoldsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @admin_user = create(:admin_user, member: @member_2)
        sign_in @admin_user
      end

      test "should lend a hold to a member" do
        member = create(:member)
        hold = create(:hold, member: member, creator: @admin_user)

        assert_difference("member.holds.active.count", -1) do
          post lend_admin_member_hold_url(member, hold)
        end
        assert_redirected_to admin_member_holds_path(member)
      end

      test "places a hold and starts it when item is available" do
        member = create(:verified_member)
        item = create(:item)

        assert_difference("member.holds.active.count") do
          post admin_member_holds_url(member), params: {hold: {item_id: item.id }}
        end

        hold = member.holds.last
        assert hold.started?
      end

      test "places a hold and does not start when item is unavailable" do
        member = create(:verified_member)
        item = create(:item)
        create(:loan, item: item)

        assert_difference("member.holds.active.count") do
          post admin_member_holds_url(member), params: {hold: { item_id: item.id } }
        end

        hold = member.holds.last
        refute hold.started?
      end

      test "places a hold and does not start when item has other holds" do
        member = create(:verified_member)
        item = create(:item)
        create(:hold, item: item)

        assert_difference("member.holds.active.count") do
          post admin_member_holds_url(member), params: {hold: { item_id: item.id } }
        end

        hold = member.holds.last
        refute hold.started?
      end
    end
  end
end

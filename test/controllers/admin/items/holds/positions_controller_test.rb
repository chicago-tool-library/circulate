require "test_helper"

module Admin
  module Items
    module Holds
      class PositionsControllerTest < ActionDispatch::IntegrationTest
        include Devise::Test::IntegrationHelpers

        setup do
          @user = create(:admin_user)
          create(:verified_member, user: @user)

          sign_in @user
        end

        test "updates positions of holds" do
          item = create(:item)
          10.times { create(:hold, item: item) }
          holds = item.holds.ordered_by_position
          hold_ids = holds.map(&:id)

          patch admin_item_hold_position_path(item.id, hold_ids[7]), params: {position: holds[2].position}, as: :turbo_stream

          assert_response :success

          reordered_hold_ids = item.holds.ordered_by_position.map(&:id)
          expected_hold_ids = hold_ids[0..1] + [hold_ids[7]] + hold_ids[2..6] + hold_ids[8..]

          assert_equal expected_hold_ids, reordered_hold_ids
        end
      end
    end
  end
end

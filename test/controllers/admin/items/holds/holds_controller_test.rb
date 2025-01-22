require "test_helper"

module Admin
  module Items
    class HoldsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @hold = create(:started_hold)
        @item = @hold.item
      end

      test "ends a hold on an item" do
        assert_difference("@item.holds.ended.count", 1) do
          patch admin_item_hold_remove_path(@item.id, @hold.id)
        end
      end
    end
  end
end

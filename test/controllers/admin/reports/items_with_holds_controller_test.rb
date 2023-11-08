require "test_helper"

module Admin
  module Reports
    class ItemsWithHoldsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user

        @item_with_holds = create(:item)
        3.times do
          create(:hold, item: @item_with_holds)
        end

        @item_without_holds = create(:item)
      end

      test "should get index" do
        get admin_reports_items_with_holds_url
        assert_response :success

        assert_select "tr[data-item-id=#{@item_with_holds.id}]"
        assert_select "tr[data-item-id=#{@item_without_holds.id}]", false, "item without holds should not appear"
      end
    end
  end
end

require "test_helper"

module Admin
  module Items
    class SearchesControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user
      end

      test "should get search" do
        create(:complete_item)

        get search_admin_items_url

        assert_response :success
      end

      test "filters items by field" do
        match = create(:item, name: "Cordless Drill")
        miss = create(:item, name: "Hammer")

        get search_admin_items_url(q: {name_cont: "Drill"})

        assert_response :success
        assert_match match.name, response.body
        assert_no_match(/#{miss.name}/, response.body)
      end

      test "sorts by active holds count" do
        item = create(:item)
        create(:hold, item: item)

        get search_admin_items_url(q: {s: "active_holds_count desc"})

        assert_response :success
      end

      test "excludes retired items by default" do
        active = create(:item, name: "Active Saw")
        retired = create(:item, :retired, name: "Retired Saw")

        get search_admin_items_url

        assert_response :success
        assert_match active.name, response.body
        assert_no_match(/#{retired.name}/, response.body)
      end
    end
  end
end

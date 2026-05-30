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

      test "filters items by bare-term query across fields" do
        match = create(:item, name: "Cordless Drill")
        miss = create(:item, name: "Hammer")

        get search_admin_items_url(query: "Drill")

        assert_response :success
        assert_match match.name, response.body
        assert_no_match(/#{miss.name}/, response.body)
      end

      test "field:value constrains match to that column" do
        dewalt = create(:item, name: "Saw", brand: "DeWalt")
        decoy = create(:item, name: "DeWalt mention in name", brand: "Makita")

        get search_admin_items_url(query: "brand:DeWalt")

        assert_response :success
        assert_match dewalt.name, response.body
        assert_no_match(/#{decoy.name}/, response.body)
      end

      test "combines field constraint with bare term using AND" do
        target = create(:item, name: "Cordless Drill", brand: "DeWalt")
        wrong_brand = create(:item, name: "Cordless Drill", brand: "Makita")
        wrong_term = create(:item, name: "Hammer", brand: "DeWalt")

        get search_admin_items_url(query: "brand:DeWalt Drill")

        assert_response :success
        assert_match target.name, response.body
        assert_no_match(/#{wrong_brand.brand}/, response.body)
        assert_no_match(/#{wrong_term.name}/, response.body)
      end

      test "quoted field value matches a multi-word phrase" do
        match = create(:item, name: "Power Drill Deluxe")
        miss = create(:item, name: "Drill bit")

        get search_admin_items_url(query: 'name:"Power Drill"')

        assert_response :success
        assert_match match.name, response.body
        assert_no_match(/#{miss.name}/, response.body)
      end

      test "unknown field prefix does not error and is treated as bare term" do
        create(:item, name: "Drill")

        get search_admin_items_url(query: "foo:bar")

        assert_response :success
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

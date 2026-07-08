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

      test "bare complete-number query finds the item" do
        item = create(:complete_item)

        get search_admin_items_url(query: item.complete_number)

        assert_response :success
        assert_match item.name, response.body
      end

      test "lone digit query returns only the exact match" do
        policy = create(:borrow_policy, code: "A")
        exact = create(:item, borrow_policy: policy, number: 114, name: "Exact Match")
        longer = create(:item, borrow_policy: policy, number: 1147, name: "Longer Number")

        get search_admin_items_url(query: "114")

        assert_response :success
        assert_match exact.name, response.body
        assert_no_match(/#{longer.name}/, response.body)
      end

      test "lone complete-number query returns only the exact match" do
        policy = create(:borrow_policy, code: "A")
        exact = create(:item, borrow_policy: policy, number: 222, name: "Exact A-222")
        decoy = create(:item, borrow_policy: policy, number: 2227, name: "Longer A-2227")

        get search_admin_items_url(query: "A-222")

        assert_response :success
        assert_match exact.name, response.body
        assert_no_match(/#{decoy.name}/, response.body)
      end

      test "lone-number exact match ignores the status filter" do
        policy = create(:borrow_policy, code: "A")
        retired = create(:item, :retired, borrow_policy: policy, number: 700, name: "Retired Saw")

        get search_admin_items_url(query: "A-700")

        assert_response :success
        assert_match retired.name, response.body
      end

      test "status checkboxes are disabled on an exact match" do
        policy = create(:borrow_policy, code: "A")
        create(:item, borrow_policy: policy, number: 800, name: "Specific")

        get search_admin_items_url(query: "A-800")

        assert_response :success
        assert_select "input[type=checkbox][name='q[status_in][]'][disabled]", count: Item.statuses.size
      end

      test "status checkboxes are enabled when search falls back to fuzzy" do
        create(:item, name: "Drill")

        get search_admin_items_url(query: "drill")

        assert_response :success
        assert_select "input[type=checkbox][name='q[status_in][]'][disabled]", count: 0
      end

      test "lone number with no exact match falls back to fuzzy search" do
        policy = create(:borrow_policy, code: "A")
        fuzzy = create(:item, borrow_policy: policy, number: 5550, name: "Drill")

        get search_admin_items_url(query: "555")

        assert_response :success
        assert_match fuzzy.name, response.body
      end

      test "multi-term query containing a number does not short-circuit to exact match" do
        policy = create(:borrow_policy, code: "A")
        exact = create(:item, borrow_policy: policy, number: 333, name: "Wrench")
        fuzzy_target = create(:item, borrow_policy: policy, number: 3334, name: "Cordless Drill")

        get search_admin_items_url(query: "333 drill")

        assert_response :success
        assert_match fuzzy_target.name, response.body
        assert_no_match(/#{exact.name}/, response.body)
      end

      test "number: constraint accepts a complete-number prefix" do
        match = create(:complete_item)
        other = create(:complete_item)

        get search_admin_items_url(query: "number:#{match.complete_number}")

        assert_response :success
        assert_match match.name, response.body
        assert_no_match(/#{other.name}/, response.body)
      end

      test "number: constraint with non-numeric value returns no rows" do
        create(:item, name: "Drill")

        get search_admin_items_url(query: "number:abc")

        assert_response :success
        assert_match "no items that match", response.body
      end

      test "LIKE wildcards in field values are escaped" do
        literal = create(:item, name: "Saw", brand: "100% pure")
        decoy = create(:item, name: "Saw", brand: "Makita")

        get search_admin_items_url(query: "brand:%")

        assert_response :success
        assert_match literal.brand, response.body
        assert_no_match(/#{decoy.brand}/, response.body)
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

require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should show item" do
    item = create(:item)
    get item_url(item)
    assert_response :success
  end

  test "shows item page for signed in user" do
    member = create(:member)
    sign_in(member.user)
    item = create(:item)

    get item_url(item)
    assert_response :success
  end

  test "only shows one of a given item regardless of how many categories it is in" do
    category = create(:category)
    child_category = create(:category, parent_id: category.id)

    item = create(:item, categories: [category, child_category])

    get items_url(category: category.id)

    assert_select "a[href='#{item_path(item)}']", count: 1
  end

  [:retired, :pending].each do |status|
    test "doesn't display the show page for a #{status} item" do
      hidden_item = create(:item, status: status)

      assert_raises ActiveRecord::RecordNotFound do
        get item_url(hidden_item)
      end
    end

    test "hides #{status} items from the item index" do
      active_item = create(:item)
      hidden_item = create(:item, status: status)

      get items_url

      assert_match active_item.complete_number, @response.body
      refute_match hidden_item.complete_number, @response.body
    end

    test "hides #{status} items from the item index for a category" do
      category = create(:category)
      hidden_item = create(:item, status: status, categories: [category])

      get items_url(category: category)

      refute_match hidden_item.complete_number, @response.body
    end
  end

  test "only displays active items on the items index, when filtering by active items" do
    active_item = create(:item, status: :active)
    maintenance_item = create(:item, status: :maintenance)
    pending_item = create(:item, status: :pending)
    retired_item = create(:item, status: :retired)

    get items_url(filter: "active")

    assert_match active_item.complete_number, @response.body
    refute_match maintenance_item.complete_number, @response.body
    refute_match pending_item.complete_number, @response.body
    refute_match retired_item.complete_number, @response.body
  end

  test "only displays active items from the category on the items index, when filtering by active items and category" do
    active_item_category = create(:category)
    hidden_item_category = create(:category)
    active_item = create(:item, categories: [active_item_category])
    maintenance_item = create(:item, status: :maintenance, categories: [active_item_category])
    pending_item = create(:item, status: :pending, categories: [active_item_category])
    retired_item = create(:item, status: :retired, categories: [active_item_category])

    get items_url(filter: "active", category: active_item_category)

    assert_match active_item.complete_number, @response.body
    refute_match maintenance_item.complete_number, @response.body
    refute_match pending_item.complete_number, @response.body
    refute_match retired_item.complete_number, @response.body
  end
end

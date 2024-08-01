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

  test "attempting to view a category that doesn't exist" do
    get items_url(category: 999999)

    assert_response :redirect
  end

  test "only shows one of a given item regardless of how many categories it is in" do
    category = create(:category)
    child_category = create(:category, parent_id: category.id)

    item = create(:item, categories: [category, child_category])

    get items_url(category: category.id)

    assert_select "a[href='#{item_path(item)}?search_result_index=0']", count: 1
  end

  [:retired, :pending].each do |status|
    test "doesn't display the show page for a #{status} item" do
      hidden_item = create(:item, status: status)

      get item_url(hidden_item)
      assert_response :not_found
    end

    test "hides #{status} items from the item index" do
      available_item = create(:item)
      hidden_item = create(:item, status: status)

      get items_url

      assert_match available_item.complete_number, @response.body
      refute_match hidden_item.complete_number, @response.body
    end

    test "hides #{status} items from the item index for a category" do
      category = create(:category)
      hidden_item = create(:item, status: status, categories: [category])

      get items_url(category: category)

      refute_match hidden_item.complete_number, @response.body
    end
  end
end

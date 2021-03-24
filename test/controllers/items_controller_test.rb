require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @item = create(:item)
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
  end

  test "shows item page for signed in user" do
    member = create(:member)
    sign_in(member.user)

    get item_url(@item)
    assert_response :success
  end

  [:retired, :pending].each do |status|
    test "doesn't display the show page for a #{status} item" do
      hidden_item = create(:item, status: status)

      assert_raises ActiveRecord::RecordNotFound do
        get item_url(hidden_item)
      end
    end

    test "hides #{status} items from the item index" do
      hidden_item = create(:item, status: status)

      get items_url

      assert_match @item.complete_number, @response.body
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

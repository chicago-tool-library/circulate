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
end

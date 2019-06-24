require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @item = items(:complete)
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get admin_items_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count") do
      post admin_items_url, params: {item: {brand: @item.brand, description: @item.description, model: @item.model, name: @item.name, serial: @item.serial, size: @item.size, strength: @item.strength, borrow_policy_id: @item.borrow_policy_id}}
    end

    assert_redirected_to admin_item_number_url(Item.last)
  end

  test "should show item" do
    get admin_item_url(@item)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch admin_item_url(@item), params: {item: {brand: @item.brand, description: @item.description, model: @item.model, name: @item.name, serial: @item.serial, size: @item.size, borrow_policy_id: @item.borrow_policy_id}}
    assert_redirected_to admin_item_url(@item)
  end

  test "should destroy item" do
    assert_difference("Item.count", -1) do
      delete admin_item_url(@item)
    end

    assert_redirected_to admin_items_url
  end
end

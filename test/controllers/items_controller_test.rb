require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @item = items(:complete)
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference('Item.count') do
      post items_url, params: { item: { brand: @item.brand, description: @item.description, model: @item.model, name: @item.name, serial: @item.serial, size: @item.size, borrow_policy_id: @item.borrow_policy_id } }
    end

    assert_redirected_to item_number_url(Item.last)
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item), params: { item: { brand: @item.brand, description: @item.description, model: @item.model, name: @item.name, serial: @item.serial, size: @item.size, borrow_policy_id: @item.borrow_policy_id } }
    assert_redirected_to item_url(@item)
  end

  test "should destroy item" do
    assert_difference('Item.count', -1) do
      delete item_url(@item)
    end

    assert_redirected_to items_url
  end
end

require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @tag = create(:tag)
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get admin_tags_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_tag_url
    assert_response :success
  end

  test "should create tag" do
    assert_difference("Tag.count") do
      post admin_tags_url, params: {tag: {name: "New Tag"}}
    end

    assert_redirected_to admin_tags_url
  end

  test "should show tag" do
    get admin_tag_url(@tag)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_tag_url(@tag)
    assert_response :success
  end

  test "should update tag" do
    patch admin_tag_url(@tag), params: {tag: {name: @tag.name}}
    assert_redirected_to admin_tags_url
  end

  test "should destroy tag" do
    assert_difference("Tag.count", -1) do
      delete admin_tag_url(@tag)
    end

    assert_redirected_to admin_tags_url
  end
end

require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @category = create(:category)
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get admin_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_admin_category_url
    assert_response :success
  end

  test "should create category" do
    assert_difference("Category.count") do
      post admin_categories_url, params: {category: {name: "New Category"}}
    end

    assert_redirected_to admin_categories_url(anchor: "category_#{Category.last.id}")
  end

  test "should get edit" do
    get edit_admin_category_url(@category)
    assert_response :success
  end

  test "should update category" do
    patch admin_category_url(@category), params: {category: {name: @category.name, slug: @category.slug}}
    assert_redirected_to admin_categories_url(anchor: "category_#{@category.id}")
  end

  test "should destroy category" do
    assert_difference("Category.count", -1) do
      delete admin_category_url(@category)
    end

    assert_redirected_to admin_categories_url
  end
end

require "test_helper"

class ItemPoolsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    create(:item_pool)
    get item_pools_url
    assert_response :success
  end

  test "shows item pool images on the index" do
    item_pool = create(:item_pool, :with_image)
    get item_pools_url
    assert_select "#item-pool-#{item_pool.id} .item-image img[alt='#{item_pool.name}']"
  end

  test "should show item pool when not signed in" do
    item_pool = create(:item_pool)
    get item_pool_url(item_pool)
    assert_response :success
  end

  test "shows the item pool's image" do
    item_pool = create(:item_pool, :with_image)
    get item_pool_url(item_pool)
    assert_select "img[alt='#{item_pool.name}']"
  end

  test "shows sign in link when not signed in" do
    item_pool = create(:item_pool)
    get item_pool_url(item_pool)
    assert_select "a[href='#{new_user_session_path}']", text: "Sign in"
  end

  test "should show item pool when signed in" do
    member = create(:member, :with_user)
    sign_in(member.user)
    item_pool = create(:item_pool)
    get item_pool_url(item_pool)
    assert_response :success
  end

  test "does not show sign in link when signed in" do
    member = create(:member, :with_user)
    sign_in(member.user)
    item_pool = create(:item_pool)
    get item_pool_url(item_pool)
    assert_select "a[href='#{new_user_session_path}']", count: 0
  end
end

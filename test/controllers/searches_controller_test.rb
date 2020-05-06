require "test_helper"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  test "searches with a query" do
    create(:item, name: "Hammer")

    get search_url(query: "hammer")

    assert_response :success
    assert_select ".items-table a", "Hammer"
  end

  test "searches with an item number" do
    hammer = create(:item, name: "Hammer")

    get search_url(query: hammer.number)

    assert_response :success
    assert_select ".items-table a", "Hammer"
  end
end

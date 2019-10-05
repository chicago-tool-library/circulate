require "test_helper"

module Admin
  class ItemsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test "searches with a query" do
      hammer = create(:item, name: "A Large Hammer")
      member = create(:member, full_name: "MC Hammer")
      get admin_search_url(query: "hammer")
      assert_response :success
      assert_select ".items-table a", "A Large Hammer"
      assert_select ".members-table a", "MC"
    end
  end
end
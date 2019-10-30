require "test_helper"

module Admin
  class ItemsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:user)
      sign_in @user
    end

    test "searches with a query" do
      hammer = create(:item, name: "A Large Hammer")
      member = create(:member, full_name: "MC Hammer")
      get admin_search_url(query: "hammer")
      assert_response :success
      assert_select ".items-table a", "A Large Hammer"
      assert_select ".members-table a", "MC"
    end

    test "finds member using the last four of the phone number" do
      member = create(:member, preferred_name: "The Count", phone_number: "1234567890")
      get admin_search_url(query: "7890")
      assert_response :success
      assert_select ".members-table a", "The Count"
    end

    test "finds a tool by number" do
      hammer = create(:item, name: "A Large Hammer")
      get admin_search_url(query: hammer.number)

      assert_response :success
      assert_select ".items-table a", "A Large Hammer"
    end
  end
end

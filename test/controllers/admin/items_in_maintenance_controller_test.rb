require "test_helper"

class Admin::ItemInMaintenanceControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create(:admin_user)
    @item = create(:complete_item, status: Item.statuses[:maintenance], name: "Hammer")
    sign_in @user
  end

  test "should get index" do
    get admin_reports_items_in_maintenance_index_url
    assert_response :success
    assert_select "a", text: @item.name
  end
end

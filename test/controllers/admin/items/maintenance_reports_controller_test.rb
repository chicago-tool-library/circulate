require "test_helper"

class MaintenanceReportsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @item = create(:item)
    @user = create(:admin_user)
    sign_in @user
  end

  test "should get index" do
    get admin_item_maintenance_reports_url(@item)
    assert_response :success
  end

  test "should get new" do
    get new_admin_item_maintenance_report_url(@item)
    assert_response :success
  end

  test "should create maintenance_report" do
    assert_difference("MaintenanceReport.count") do
      post admin_item_maintenance_reports_url(@item), params: {maintenance_report_form: {title: "Update", body: "Did some work", time_spent: 45, status: "maintenance_parts"}}
    end

    assert_redirected_to admin_item_maintenance_reports_url(@item)
  end

  # test "should show maintenance_report" do
  #   get maintenance_report_url(@maintenance_report)
  #   assert_response :success
  # end

  test "should get edit" do
    @maintenance_report = create(:maintenance_report, item: @item)

    get edit_admin_item_maintenance_report_url(@item, @maintenance_report)

    assert_response :success
  end

  test "should update maintenance_report" do
    @maintenance_report = create(:maintenance_report, item: @item)

    patch admin_item_maintenance_report_url(@item, @maintenance_report), params: {maintenance_report: {body: "Did more work", time_spent: 50}}

    assert_redirected_to admin_item_maintenance_reports_url(@item)
  end

  test "should destroy maintenance_report" do
    @maintenance_report = create(:maintenance_report, item: @item)

    assert_difference("MaintenanceReport.count", -1) do
      delete admin_item_maintenance_report_url(@item, @maintenance_report)
    end

    assert_redirected_to admin_item_maintenance_reports_url(@item)
  end
end

require "test_helper"

class MonthlyAdjustmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:admin)
    sign_in @user
  end

  test "should get index" do
    get admin_monthly_adjustments_url
    assert_response :success
  end
end

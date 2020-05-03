require "test_helper"

module Admin
  class MonthlyActivitiesControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = users(:admin)
      sign_in @user
    end

    test "should get index" do
      create(:member, created_at: 2.months.ago)
      create(:loan, created_at: 1.months.ago)

      get admin_monthly_activities_url
      assert_response :success
    end
  end
end

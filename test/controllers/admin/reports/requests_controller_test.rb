require "test_helper"

module Admin
  module Reports
    class RequestsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        3.times do
          create(:member)
        end
        @user = create(:admin_user)
        sign_in @user
      end

      test "should get index" do
        get admin_reports_member_requests_url
        assert_response :success
      end
    end
  end
end

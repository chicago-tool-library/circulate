require "test_helper"

module Admin
  module Reports
    class ShiftsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user
      end

      test "displays volunteer shifts" do
        create(:volunteer_shift_event, start: 24.hours.from_now, finish: 26.hours.from_now)

        get admin_reports_shifts_url
        assert_response :success

        assert_match "Librarian", response.body
      end
    end
  end
end

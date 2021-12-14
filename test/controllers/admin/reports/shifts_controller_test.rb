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
        create(:volunteer_shift_event, start: Time.current + 24.hours, finish: Time.current + 26.hours)

        get admin_reports_shifts_url
        assert_response :success

        assert_match "Librarian", response.body
      end
    end
  end
end

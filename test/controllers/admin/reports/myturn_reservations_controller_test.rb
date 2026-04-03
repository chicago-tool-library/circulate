require "test_helper"

module Admin
  module Reports
    class MyturnReservationsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        @user = create(:admin_user)
        sign_in @user
      end

      test "renders index when myturn is not configured" do
        Myturn.stub(:configured?, false) do
          get admin_reports_myturn_reservations_url
          assert_response :success
          assert_select "p", /not configured/i
        end
      end

      test "renders index with reservations from myturn" do
        today = Date.current
        reservations = [
          {
            "id" => 1,
            "dateTime" => today.to_time.iso8601,
            "pickupStartTime" => "10:00 AM",
            "pickupEndTime" => "11:00 AM",
            "length" => 7,
            "numItems" => 3,
            "pickupLocation" => "Camping Gear",
            "user" => {"firstName" => "Jane", "lastName" => "Doe"},
            "status" => {"name" => "APPROVED"}
          },
          {
            "id" => 2,
            "dateTime" => (today - 5.days).to_time.iso8601,
            "pickupStartTime" => "1:00 PM",
            "pickupEndTime" => "2:00 PM",
            "length" => 5,
            "numItems" => 2,
            "pickupLocation" => "Camping Gear",
            "user" => {"firstName" => "John", "lastName" => "Smith"},
            "status" => {"name" => "APPROVED"}
          }
        ]

        stub_client = StubMyturnClient.new(reservations)

        Myturn.stub(:configured?, true) do
          Myturn::Client.stub(:new, stub_client) do
            get admin_reports_myturn_reservations_url
            assert_response :success

            # Jane has a pickup today
            assert_select "td", /Jane/

            # John's reservation started 5 days ago with length 5, so dropoff is today
            assert_select "td", /John/
          end
        end
      end

      test "renders index with day parameter" do
        stub_client = StubMyturnClient.new([])

        Myturn.stub(:configured?, true) do
          Myturn::Client.stub(:new, stub_client) do
            get admin_reports_myturn_reservations_url(day: "2026-06-15")
            assert_response :success
            assert_select "b", "Monday, June 15, 2026"
          end
        end
      end

      test "handles api errors gracefully" do
        stub_client = StubMyturnClient.new(RuntimeError.new("Connection refused"))

        Myturn.stub(:configured?, true) do
          Myturn::Client.stub(:new, stub_client) do
            get admin_reports_myturn_reservations_url
            assert_response :success
            assert_select ".toast-error"
          end
        end
      end

      class StubMyturnClient
        def initialize(result)
          @result = result
        end

        def reservations(**)
          raise @result if @result.is_a?(Exception)
          @result
        end
      end
    end
  end
end

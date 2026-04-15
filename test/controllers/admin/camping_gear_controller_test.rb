require "test_helper"

module Admin
  class CampingGearControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = create(:admin_user)
      sign_in @user
      ENV["MYTURN_USERNAME"] = "test"
      ENV["MYTURN_PASSWORD"] = "test"
    end

    teardown do
      ENV.delete("MYTURN_USERNAME")
      ENV.delete("MYTURN_PASSWORD")
    end

    test "renders index when myturn is not configured" do
      ENV.delete("MYTURN_USERNAME")
      ENV.delete("MYTURN_PASSWORD")

      get admin_camping_gear_index_url
      assert_response :success
      assert_select "p", /not configured/i
    end

    test "renders index with reservations from myturn" do
      day = "2026-06-15"
      reservations = [
        {
          "id" => 1,
          "dateTime" => "2026-06-15T00:00:00.000-05:00",
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
          "dateTime" => "2026-06-10T00:00:00.000-05:00",
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

      Myturn::Client.stub(:new, stub_client) do
        get admin_camping_gear_index_url(day: day)
        assert_response :success

        # Jane has a pickup on June 15
        assert_select "td", /Jane/

        # John's reservation started June 10 with length 5, so dropoff is June 15
        assert_select "td", /John/
      end
    end

    test "renders index with day parameter" do
      stub_client = StubMyturnClient.new([])

      Myturn::Client.stub(:new, stub_client) do
        get admin_camping_gear_index_url(day: "2026-06-15")
        assert_response :success
        assert_select "b", "Monday, June 15, 2026"
      end
    end

    test "handles api errors gracefully" do
      stub_client = StubMyturnClient.new(RuntimeError.new("Connection refused"))

      Myturn::Client.stub(:new, stub_client) do
        get admin_camping_gear_index_url
        assert_response :success
        assert_select ".toast-error"
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

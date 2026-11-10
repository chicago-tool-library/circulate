require "test_helper"

module Admin
  module Reservations
    class StatusesControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        sign_in create(:admin_user)

        pool = create(:item_pool, :unnumbered, unnumbered_count: 5, usage_fee: 10)
        @reservation = create(:reservation, :borrowed)
        hold = create(:reservation_hold, reservation: @reservation, item_pool: pool, quantity: 2)
        @loan = @reservation.reservation_loans.create!(reservation_hold: hold, quantity: 2, checked_out_at: Time.current)
      end

      test "completes check-in once all items are returned and charges usage fees" do
        @loan.update!(checked_in_at: Time.current)

        assert_difference -> { Adjustment.usage_fee.count } => 1 do
          patch admin_reservation_status_url(@reservation), params: {event: "check_in"}
        end

        assert_redirected_to admin_reservation_loans_url(@reservation)
        assert_equal "returned", @reservation.reload.status
        assert_equal Money.new(-20_00), @reservation.adjustments.sole.amount
      end

      test "refuses to complete check-in while items are still out" do
        assert_no_difference -> { Adjustment.count } do
          patch admin_reservation_status_url(@reservation), params: {event: "check_in"}
        end

        assert_redirected_to admin_reservation_loans_url(@reservation)
        assert_equal "borrowed", @reservation.reload.status
      end

      test "marks a reservation unresolved and later resolves it" do
        patch admin_reservation_status_url(@reservation), params: {event: "unresolve"}
        assert_equal "unresolved", @reservation.reload.status
        assert_empty @reservation.adjustments

        patch admin_reservation_status_url(@reservation), params: {event: "resolve"}
        assert_equal "returned", @reservation.reload.status
        assert_equal 1, @reservation.adjustments.usage_fee.count
      end

      test "rejects events that aren't valid from the current status" do
        patch admin_reservation_status_url(@reservation), params: {event: "build"}

        assert_redirected_to admin_reservation_loans_url(@reservation)
        assert_equal "borrowed", @reservation.reload.status
      end

      test "rejects unknown events" do
        patch admin_reservation_status_url(@reservation), params: {event: "cancel"}

        assert_equal "borrowed", @reservation.reload.status
      end
    end
  end
end

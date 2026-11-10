require "test_helper"

module Admin
  module Reservations
    class CheckInsControllerTest < ActionDispatch::IntegrationTest
      include Devise::Test::IntegrationHelpers

      setup do
        sign_in create(:admin_user)
      end

      test "doesn't allow undoing a return once the reservation is returned" do
        pool = create(:item_pool, :unnumbered, unnumbered_count: 5)
        reservation = create(:reservation, :returned)
        hold = create(:reservation_hold, reservation:, item_pool: pool, quantity: 1)
        loan = reservation.reservation_loans.create!(reservation_hold: hold, quantity: 1, checked_out_at: 1.day.ago, checked_in_at: 1.hour.ago)

        delete admin_reservation_check_in_url(reservation, loan)

        assert_redirected_to admin_reservation_loans_url(reservation)
        assert loan.reload.checked_in_at
      end

      test "allows returning items on an unresolved reservation" do
        pool = create(:item_pool, :unnumbered, unnumbered_count: 5)
        reservation = create(:reservation, :unresolved)
        hold = create(:reservation_hold, reservation:, item_pool: pool, quantity: 1)
        loan = reservation.reservation_loans.create!(reservation_hold: hold, quantity: 1, checked_out_at: 1.day.ago)

        post admin_reservation_check_ins_url(reservation), params: {reservation_loan_lookup_form: {reservation_loan_id: loan.id}}, as: :turbo_stream

        assert_response :success
        assert loan.reload.checked_in_at
      end
    end
  end
end

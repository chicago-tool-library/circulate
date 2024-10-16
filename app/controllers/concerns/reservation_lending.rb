module ReservationLending
  extend self

  # Returns a Result containing either a newly created ReservationLoan or an error
  def add_pending_item_to_reservation(pending_reservation_item)
    reservation = pending_reservation_item.reservation

    reservation.transaction do
      item_pool = pending_reservation_item.reservable_item.item_pool
      reservation_hold = reservation.reservation_holds.find_or_initialize_by(item_pool:)

      if reservation_hold.persisted?
        reservation_hold.quantity += 1
      else
        reservation_hold.quantity = 1
      end

      if reservation_hold.save
        reservation_loan = reservation.reservation_loans.create(reservable_item: pending_reservation_item.reservable_item, reservation_hold:)
        if reservation_loan.save
          pending_reservation_item.destroy!
          Result.success(reservation_loan)
        else
          Result.failure(reservation_loan)
        end
      else
        Result.failure(reservation_hold)
      end
    end
  end
end

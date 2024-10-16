require "test_helper"

class ReservationLendingTest < ActiveSupport::TestCase
  test "adds a new pending item to a reservation" do
    reservation = create(:reservation, :building)
    pending_reservation_item = create(:pending_reservation_item, reservation: reservation)

    assert_equal 0, reservation.reservation_holds.count

    result = ReservationLending.add_pending_item_to_reservation(pending_reservation_item)

    assert result.success?
    assert_equal 1, reservation.reservation_holds.count

    reservation_loan = result.value
    assert_equal pending_reservation_item.reservable_item, reservation_loan.reservable_item

    assert pending_reservation_item.destroyed?
  end

  test "adds a pending item that already exists to a reservation" do
    item_pool = create(:item_pool)
    reservable_items = 3.times.map { create(:reservable_item, item_pool:) }

    reservation = create(:reservation, :building)
    existing_reservation_hold = create(:reservation_hold, item_pool:, reservation:, quantity: 2)
    pending_reservation_item = create(:pending_reservation_item,
      reservable_item: reservable_items.first,
      reservation:)

    assert_equal 1, reservation.reservation_holds.count
    assert_equal 2, existing_reservation_hold.quantity

    result = ReservationLending.add_pending_item_to_reservation(pending_reservation_item)

    assert result.success?
    assert_equal 1, reservation.reservation_holds.count

    reservation_loan = result.value
    assert_equal pending_reservation_item.reservable_item, reservation_loan.reservable_item
    assert_equal existing_reservation_hold, reservation_loan.reservation_hold

    existing_reservation_hold.reload
    assert_equal 3, existing_reservation_hold.quantity

    assert pending_reservation_item.destroyed?
  end

  test "creating a reservation hold" do
    reservation = create(:reservation)
    reservable_item = create(:reservable_item)

    result = ReservationLending.create_reservation_hold(
      reservation:,
      item_pool_id: reservable_item.item_pool_id,
      quantity: 1
    )

    assert result.success?

    reservation_hold = result.value

    assert_equal reservation.started_at, reservation_hold.started_at
    assert_equal reservation.ended_at, reservation_hold.ended_at
  end
end

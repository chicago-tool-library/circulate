require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  test "validations" do
    reservation = build(:reservation)
    reservation.valid?
    assert_equal({}, reservation.errors.messages)

    reservation = Reservation.new

    assert reservation.invalid?
    assert_equal ["can't be blank"], reservation.errors[:name]
    assert_equal ["can't be blank"], reservation.errors[:started_at]
    assert_equal ["can't be blank"], reservation.errors[:ended_at]

    reservation = Reservation.new(started_at: 1.day.ago, ended_at: 3.days.ago)

    assert reservation.invalid?
    assert_equal ["end date must be after the start date"], reservation.errors[:ended_at]
  end

  test "dropoff event must be after the pickup event" do
    base_time = 2.days.from_now.at_noon
    first_event = create(:event, calendar_id: Event.appointment_slot_calendar_id, start: base_time, finish: base_time + 1.hour)
    last_event = create(:event, calendar_id: Event.appointment_slot_calendar_id, start: base_time + 2.hours, finish: base_time + 3.hours)

    reservation = build(:reservation, :pending, pickup_event: last_event, dropoff_event: first_event)

    assert reservation.invalid?
    assert_equal ["must be after pickup event"], reservation.errors[:dropoff_event_id]
  end

  test "usage_fee_total adds up the fees for every hold" do
    reservation = create(:reservation)
    tent_pool = create(:item_pool, :unnumbered, unnumbered_count: 5, usage_fee: 10)
    canopy_pool = create(:item_pool, :unnumbered, unnumbered_count: 5, usage_fee: 25)
    create(:reservation_hold, reservation:, item_pool: tent_pool, quantity: 2)
    create(:reservation_hold, reservation:, item_pool: canopy_pool, quantity: 1)

    assert_equal Money.new(45_00), reservation.reload.usage_fee_total
  end

  test "usage_fee_total is zero without holds" do
    assert_equal Money.new(0), create(:reservation).usage_fee_total
  end

  def borrowed_reservation_with_fee(fee: 10, quantity: 2)
    pool = create(:item_pool, :unnumbered, unnumbered_count: 5, usage_fee: fee)
    reservation = create(:reservation, :borrowed)
    hold = create(:reservation_hold, reservation:, item_pool: pool, quantity:)
    loan = reservation.reservation_loans.create!(reservation_hold: hold, quantity:, checked_out_at: Time.current)
    [reservation.reload, loan]
  end

  test "all_items_returned? requires every loan to be checked in" do
    reservation, loan = borrowed_reservation_with_fee
    refute reservation.all_items_returned?

    loan.update!(checked_in_at: Time.current)
    assert reservation.all_items_returned?
  end

  test "all_items_returned? is false without any loans" do
    refute create(:reservation, :borrowed).all_items_returned?
  end

  test "check_in is only possible once all items are returned" do
    reservation, loan = borrowed_reservation_with_fee
    refute reservation.manager.can?(:check_in)

    loan.update!(checked_in_at: Time.current)
    assert reservation.manager.can?(:check_in)
  end

  test "borrowing marks loans as checked out" do
    pool = create(:item_pool, :unnumbered, unnumbered_count: 5)
    reservation = create(:reservation, :ready)
    hold = create(:reservation_hold, reservation:, item_pool: pool, quantity: 1)
    loan = reservation.reservation_loans.create!(reservation_hold: hold, quantity: 1)

    freeze_time do
      reservation.manager.trigger(:borrow)
      reservation.save!

      assert_equal Time.current, loan.reload.checked_out_at
    end
  end

  test "returned items are available for other reservations" do
    pool = create(:item_pool)
    item = create(:reservable_item, item_pool: pool)
    reservation = create(:reservation, :ready)
    hold = create(:reservation_hold, reservation:, item_pool: pool)
    loan = reservation.reservation_loans.create!(reservation_hold: hold, reservable_item: item)
    reservation.manager.trigger(:borrow)
    reservation.save!
    loan.update!(checked_in_at: Time.current)

    other_reservation = create(:reservation, :building, started_at: 3.weeks.from_now, ended_at: 4.weeks.from_now)
    other_hold = create(:reservation_hold, reservation: other_reservation, item_pool: pool)
    other_loan = other_reservation.reservation_loans.build(reservation_hold: other_hold, reservable_item: item)

    assert other_loan.valid?, other_loan.errors.full_messages.to_sentence
  end

  test "checking in charges the member for usage fees" do
    reservation, loan = borrowed_reservation_with_fee(fee: 10, quantity: 2)
    loan.update!(checked_in_at: Time.current)

    assert_difference -> { reservation.member.adjustments.count } => 1 do
      reservation.manager.trigger(:check_in)
      reservation.save!
    end

    adjustment = reservation.adjustments.sole
    assert adjustment.usage_fee?
    assert_equal Money.new(-20_00), adjustment.amount
    assert_equal reservation.member, adjustment.member
    assert_equal "returned", reservation.reload.status
  end

  test "resolving an unresolved reservation charges the member for usage fees" do
    reservation, _loan = borrowed_reservation_with_fee(fee: 5, quantity: 1)
    reservation.manager.trigger(:unresolve)
    reservation.save!
    assert_empty reservation.adjustments

    reservation.manager.trigger(:resolve)
    reservation.save!

    assert_equal Money.new(-5_00), reservation.adjustments.sole.amount
  end

  test "usage fees are only charged once" do
    reservation, loan = borrowed_reservation_with_fee
    loan.update!(checked_in_at: Time.current)
    reservation.manager.trigger(:check_in)
    reservation.save!

    reservation.update_columns(status: Reservation.statuses[:unresolved])
    reservation = Reservation.find(reservation.id)
    reservation.manager.trigger(:resolve)

    assert_no_difference -> { Adjustment.count } do
      reservation.save!
    end
  end

  test "no adjustment is created when there are no usage fees" do
    reservation, loan = borrowed_reservation_with_fee(fee: 0)
    loan.update!(checked_in_at: Time.current)

    assert_no_difference -> { Adjustment.count } do
      reservation.manager.trigger(:check_in)
      reservation.save!
    end
  end
end

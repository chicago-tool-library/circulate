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

  %i[
    pending
  ].each do |status|
    test "a reservation with a status of #{status} doesn't require pickup or dropoff events" do
      reservation = build(:reservation, status, pickup_event: nil, dropoff_event: nil)

      reservation.valid?

      assert_equal({}, reservation.errors.messages)
    end
  end

  %i[
    requested
    approved
    rejected
    obsolete
    building
    ready
    borrowed
    returned
    unresolved
    cancelled
  ].each do |status|
    test "a reservation with a status of #{status} requires a pickup event but not a dropoff event" do
      reservation = build(:reservation, status, pickup_event: nil, dropoff_event: nil)

      assert reservation.invalid?

      assert_equal ["can't be blank"], reservation.errors[:pickup_event]
      assert reservation.errors[:dropoff_event].blank?

      reservation.pickup_event = create(:event)
      assert reservation.valid?
      assert reservation.save
    end
  end
end

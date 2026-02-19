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
end

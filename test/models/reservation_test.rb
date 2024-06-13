require "test_helper"

class ReservationTest < ActiveSupport::TestCase
  test "validations" do
    reservation = Reservation.new

    assert reservation.invalid?
    assert_equal ["can't be blank"], reservation.errors[:name]
    assert_equal ["can't be blank"], reservation.errors[:started_at]
    assert_equal ["can't be blank"], reservation.errors[:ended_at]

    reservation = Reservation.new(started_at: 1.day.ago, ended_at: 3.days.ago)

    assert reservation.invalid?
    assert_equal ["end date must be after the start date"], reservation.errors[:ended_at]
  end

  test "must start within the range specified by the library" do
    library = Library.first!
    library.update!(minimum_reservation_start_distance: 3, maximum_reservation_start_distance: 7)

    reservation = build(:reservation, library:, started_at: 3.days.from_now, ended_at: 10.days.from_now)
    assert reservation.valid?

    reservation = build(:reservation, library:, started_at: 7.days.from_now, ended_at: 10.days.from_now)
    assert reservation.valid?

    reservation = build(:reservation, library:, started_at: 1.days.from_now, ended_at: 10.days.from_now)
    assert reservation.invalid?
    assert_equal ["must be between #{3.days.from_now.to_date} and #{7.days.from_now.to_date}"], reservation.errors[:started_at]

    reservation = build(:reservation, library:, started_at: 8.days.from_now, ended_at: 10.days.from_now)
    assert reservation.invalid?
    assert_equal ["must be between #{3.days.from_now.to_date} and #{7.days.from_now.to_date}"], reservation.errors[:started_at]
  end

  test "must not be longer than the length specified by the library" do
    library = Library.first!
    library.update!(maximum_reservation_length: 10)

    reservation = build(:reservation, library:, started_at: 3.days.from_now, ended_at: 13.days.from_now)
    assert reservation.valid?

    reservation = build(:reservation, library:, started_at: 3.days.from_now, ended_at: 14.days.from_now)
    assert reservation.invalid?
    assert_equal ["must not exceed 10 days"], reservation.errors[:ended_at]
  end
end

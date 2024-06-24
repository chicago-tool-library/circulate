require "test_helper"

class ReservationDateValidatorTest < ActiveSupport::TestCase
  def associate_reservation_with_policy!(reservation, reservation_policy)
    item_pool = create(:item_pool, reservation_policy:)
    create(:reservable_item, item_pool:)
    create(:reservation_hold, reservation:, item_pool:)
  end

  test "#reservation_policies is the associated reservation policies" do
    create(:reservation_policy, default: true)
    policy_a = create(:reservation_policy)
    policy_b = create(:reservation_policy)
    reservation = create(:reservation)

    associate_reservation_with_policy!(reservation, policy_a)
    associate_reservation_with_policy!(reservation, policy_b)

    validator = ReservationDateValidator.new(reservation:)

    assert_equal [policy_a, policy_b], validator.reservation_policies
  end

  test "#reservation_policies is the default reservation policy when there are no associated reservation policies" do
    default_policy = create(:reservation_policy, default: true)
    reservation = create(:reservation)
    validator = ReservationDateValidator.new(reservation:)

    assert_equal [default_policy], validator.reservation_policies
  end

  test "#errors is blank when there are none" do
    default_reservation_policy = create(:reservation_policy, default: true, minimum_start_distance: 1)
    reservation = create(:reservation, started_at: 2.days.from_now)
    validator = ReservationDateValidator.new(reservation:, default_reservation_policy:)
    errors = validator.errors

    assert errors.blank?
  end

  test "#errors shows when a reservation is too long (handles multiple policy durations)" do
    policy_a = create(:reservation_policy, maximum_duration: 10)
    policy_b = create(:reservation_policy, maximum_duration: 5)
    policy_c = create(:reservation_policy, maximum_duration: 3)
    reservation = create(:reservation, started_at: 3.day.from_now, ended_at: 9.days.from_now)
    associate_reservation_with_policy!(reservation, policy_a)
    associate_reservation_with_policy!(reservation, policy_b)
    associate_reservation_with_policy!(reservation, policy_c)
    validator = ReservationDateValidator.new(reservation:)
    errors = validator.errors

    assert errors.present?

    expected_error_messages = [
      "duration is longer than allowed by #{policy_b.name} (#{policy_b.maximum_duration} days)",
      "duration is longer than allowed by #{policy_c.name} (#{policy_c.maximum_duration} days)"
    ]

    assert_equal expected_error_messages, errors[:duration]
    assert_equal [:duration], errors.keys
  end

  test "#errors shows when a reservation starts too soon (handles multiple policy distance minimums)" do
    policy_a = create(:reservation_policy, minimum_start_distance: 2)
    policy_b = create(:reservation_policy, minimum_start_distance: 5)
    policy_c = create(:reservation_policy, minimum_start_distance: 10)
    reservation = create(:reservation, started_at: 4.days.from_now, ended_at: 1.week.from_now)
    associate_reservation_with_policy!(reservation, policy_a)
    associate_reservation_with_policy!(reservation, policy_b)
    associate_reservation_with_policy!(reservation, policy_c)
    validator = ReservationDateValidator.new(reservation:)
    errors = validator.errors

    assert errors.present?

    expected_error_messages = [
      "starts sooner than allowed by #{policy_b.name} (#{policy_b.minimum_start_distance} days)",
      "starts sooner than allowed by #{policy_c.name} (#{policy_c.minimum_start_distance} days)"
    ]

    assert_equal expected_error_messages, errors[:minimum_start_distance]
    assert_equal [:minimum_start_distance], errors.keys
  end

  test "#errors shows when a reservation starts too late (handles multiple policy distance maximums)" do
    policy_a = create(:reservation_policy, maximum_start_distance: 10)
    policy_b = create(:reservation_policy, maximum_start_distance: 5)
    policy_c = create(:reservation_policy, maximum_start_distance: 4)
    reservation = create(:reservation, started_at: 9.days.from_now, ended_at: 12.days.from_now)
    associate_reservation_with_policy!(reservation, policy_a)
    associate_reservation_with_policy!(reservation, policy_b)
    associate_reservation_with_policy!(reservation, policy_c)
    validator = ReservationDateValidator.new(reservation:)
    errors = validator.errors

    assert errors.present?

    expected_error_messages = [
      "starts later than allowed by #{policy_b.name} (#{policy_b.maximum_start_distance} days)",
      "starts later than allowed by #{policy_c.name} (#{policy_c.maximum_start_distance} days)"
    ]

    assert_equal expected_error_messages, errors[:maximum_start_distance]
    assert_equal [:maximum_start_distance], errors.keys
  end

  test "#errors shows when multiple bounds make the reservation impossible" do
    policy_a = create(:reservation_policy, maximum_start_distance: 10)
    policy_b = create(:reservation_policy, minimum_start_distance: 6)
    policy_c = create(:reservation_policy, maximum_start_distance: 4)
    reservation = create(:reservation, started_at: 9.days.from_now, ended_at: 12.days.from_now)
    associate_reservation_with_policy!(reservation, policy_a)
    associate_reservation_with_policy!(reservation, policy_b)
    associate_reservation_with_policy!(reservation, policy_c)
    validator = ReservationDateValidator.new(reservation:)
    errors = validator.errors

    assert errors.present?

    expected_error_messages = [
      "impossible to find valid reservation dates (#{policy_b.name} and #{policy_c.name} are mutually exclusive)"
    ]

    assert_equal expected_error_messages, errors[:impossible]
  end
end

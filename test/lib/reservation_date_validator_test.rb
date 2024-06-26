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
    # policy_a    |----------|
    # policy_b    |-----|
    # policy_c    |---|
    # reservation |------|
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
    assert_equal [policy_b, policy_c], errors.maximum_duration
  end

  test "#errors shows when a reservation starts too soon (handles multiple policy distance minimums)" do
    # policy_a    |xx---------------|
    # policy_b    |xxxxx------------|
    # policy_c    |xxxxxxxxxx-------|
    # reservation |---*-------------|
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
    assert_equal [policy_b, policy_c], errors.minimum_start_distance
  end

  test "#errors shows when a reservation starts too late (handles multiple policy distance maximums)" do
    # policy_a    |---------xx|
    # policy_b    |-----xxxxxx|
    # policy_c    |----xxxxxxx|
    # reservation |--------*--|
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
    assert_equal [policy_b, policy_c], errors.maximum_start_distance
  end

  test "#errors shows when multiple bounds make the reservation impossible" do
    # policy_a    |---------xx|
    # policy_b    |xxxxxx-----|
    # policy_c    |----xxxxxxx|
    # reservation |--------*--|
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
    assert_equal [[policy_b, policy_c]], errors.impossible
  end

  test "Errors has the correct defaults" do
    errors = ReservationDateValidator::Errors.new

    assert_equal [], errors.maximum_duration
    assert_equal [], errors.minimum_start_distance
    assert_equal [], errors.maximum_start_distance
    assert_equal [], errors.impossible
  end

  test "Errors#empty? is true when it lacks reservation policies and false otherwise" do
    reservation_policy = ReservationPolicy.new
    errors = ReservationDateValidator::Errors.new

    assert errors.empty?

    errors = ReservationDateValidator::Errors.new
    errors.maximum_duration << reservation_policy

    refute errors.empty?

    errors = ReservationDateValidator::Errors.new
    errors.minimum_start_distance << reservation_policy

    refute errors.empty?

    errors = ReservationDateValidator::Errors.new
    errors.maximum_start_distance << reservation_policy

    refute errors.empty?

    errors = ReservationDateValidator::Errors.new
    errors.impossible << [reservation_policy, ReservationPolicy.new]

    refute errors.empty?
  end
end

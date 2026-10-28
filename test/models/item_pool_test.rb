require "test_helper"

class ItemPoolTest < ActiveSupport::TestCase
  setup do
    @starts = Time.zone.parse("2024-02-15").beginning_of_day
    @ends = Time.zone.parse("2024-02-22").end_of_day
  end

  test "max_reservable_percentage_points is calculated" do
    item_pool = create(:item_pool, max_reservable_percent: 0.7)

    assert_equal 70, item_pool.max_reservable_percentage_points
  end

  test "max_reservable_percentage_points= sets max_reservable_percent" do
    item_pool = create(:item_pool)
    item_pool.max_reservable_percentage_points = 56

    assert_equal 0.56, item_pool.max_reservable_percent
    assert item_pool.valid?
  end

  test "no items available with no reservable items" do
    item_pool = create(:item_pool)

    assert_equal 0, item_pool.max_available_between(@starts, @ends)
  end

  test "multiple items available with no reservations" do
    reservable_item = create(:reservable_item)
    2.times { create(:reservable_item, item_pool: reservable_item.item_pool) }

    assert_equal 3, reservable_item.item_pool.max_available_between(@starts, @ends)
  end

  test "handles reservations aligned with the query" do
    # reservation  |-------|
    # query        |-------|

    reservable_item = create(:reservable_item)
    item_pool = reservable_item.item_pool
    2.times { create(:reservable_item, item_pool: item_pool) }

    reservation = create(:reservation, started_at: @starts, ended_at: @ends)
    create(:reservation_hold, reservation: reservation, item_pool: item_pool, quantity: 1)

    assert_equal 2, reservable_item.item_pool.max_available_between(@starts, @ends)
  end

  test "handles multiple reservations that don't overlap" do
    # reservation 1  |-------|
    # reservation 2            |-------|
    # query               |-------|

    reservable_item = create(:reservable_item)
    item_pool = reservable_item.item_pool
    2.times { create(:reservable_item, item_pool: item_pool) }

    reservation1 = create(:reservation, started_at: @starts - 4.days, ended_at: @ends - 4.days)
    create(:reservation_hold, reservation: reservation1, item_pool: item_pool, quantity: 1)

    reservation2 = create(:reservation, started_at: @starts + 4.days, ended_at: @ends + 4.days)
    create(:reservation_hold, reservation: reservation2, item_pool: item_pool, quantity: 1)

    assert_equal 2, reservable_item.item_pool.max_available_between(@starts, @ends)
  end

  test "handles overlapping reservations" do
    # reservation 1  |-------|
    # reservation 2      |-------|
    # query            |-------|

    reservable_item = create(:reservable_item)
    item_pool = reservable_item.item_pool
    2.times { create(:reservable_item, item_pool: item_pool) }

    reservation1 = create(:reservation, started_at: @starts - 2.days, ended_at: @ends - 2.days)
    create(:reservation_hold, reservation: reservation1, item_pool: item_pool, quantity: 1)

    reservation2 = create(:reservation, started_at: @starts + 2.days, ended_at: @ends + 2.days)
    create(:reservation_hold, reservation: reservation2, item_pool: item_pool, quantity: 1)

    assert_equal 1, reservable_item.item_pool.max_available_between(@starts, @ends)
  end

  test "handles multiple reservations within query bounds" do
    # reservation 1   |-|
    # reservation 2      |-|
    # reservation 3         |-|
    # query          |----------|

    reservable_item = create(:reservable_item)
    item_pool = reservable_item.item_pool
    2.times { create(:reservable_item, item_pool: item_pool) }

    reservation1 = create(:reservation, started_at: @starts, ended_at: @starts.end_of_day + 2.days)
    create(:reservation_hold, reservation: reservation1, item_pool: item_pool, quantity: 1)

    reservation2 = create(:reservation, started_at: @starts + 3.days, ended_at: @starts.end_of_day + 4.days)
    create(:reservation_hold, reservation: reservation2, item_pool: item_pool, quantity: 1)

    reservation3 = create(:reservation, started_at: @starts + 5.days, ended_at: @starts.end_of_day + 6.days)
    create(:reservation_hold, reservation: reservation3, item_pool: item_pool, quantity: 1)

    assert_equal 2, reservable_item.item_pool.max_available_between(@starts, @ends)
  end

  test "handles multiple overlapping reservations within query bounds" do
    # reservation 1   |----|
    # reservation 2      |-|
    # reservation 3         |-|
    # query          |----------|

    reservable_item = create(:reservable_item)
    item_pool = reservable_item.item_pool
    2.times { create(:reservable_item, item_pool: item_pool) }

    reservation1 = create(:reservation, started_at: @starts, ended_at: @starts.end_of_day + 4.days)
    create(:reservation_hold, reservation: reservation1, item_pool: item_pool, quantity: 1)

    reservation2 = create(:reservation, started_at: @starts + 3.days, ended_at: @starts.end_of_day + 4.days)
    create(:reservation_hold, reservation: reservation2, item_pool: item_pool, quantity: 1)

    reservation3 = create(:reservation, started_at: @starts + 5.days, ended_at: @starts.end_of_day + 6.days)
    create(:reservation_hold, reservation: reservation3, item_pool: item_pool, quantity: 1)

    assert_equal 1, reservable_item.item_pool.max_available_between(@starts, @ends)
  end

  test "limits how many items can be on a reservation using max_reservable_percent" do
    item_pool = create(:item_pool, max_reservable_percent: 0.5)
    8.times { create(:reservable_item, item_pool: item_pool) }

    assert_equal 4, item_pool.max_reservable_quantity(per_reservation: true)

    # make sure we're rounding down
    item_pool.reservable_items.last.destroy!
    assert_equal 3, item_pool.max_reservable_quantity(per_reservation: true)
  end

  test "defaults to no usage fee" do
    item_pool = build(:item_pool)

    assert_equal Money.new(0), item_pool.usage_fee
    assert_equal Money.new(0), item_pool.periodic_fee
    assert_equal 1, item_pool.periodic_fee_period
    refute item_pool.usage_fee?
  end

  test "validates fees are not negative" do
    item_pool = build(:item_pool, usage_fee: -1, periodic_fee: -1)

    refute item_pool.valid?
    assert item_pool.errors.of_kind?(:usage_fee, :greater_than_or_equal_to)
    assert item_pool.errors.of_kind?(:periodic_fee, :greater_than_or_equal_to)
  end

  test "validates the periodic fee period" do
    refute build(:item_pool, periodic_fee_period: 0).valid?
    refute build(:item_pool, periodic_fee_period: 1.5).valid?
    refute build(:item_pool, periodic_fee_period: 366).valid?
    assert build(:item_pool, periodic_fee_period: 7).valid?
  end

  test "usage_fee_for charges the usage fee once" do
    item_pool = build(:item_pool, usage_fee: 10)

    assert_equal Money.new(10_00), item_pool.usage_fee_for(@starts, @starts + 1.day)
    assert_equal Money.new(10_00), item_pool.usage_fee_for(@starts, @starts + 30.days)
  end

  test "usage_fee_for charges the periodic fee for each started period" do
    item_pool = build(:item_pool, periodic_fee: 2)

    assert_equal Money.new(2_00), item_pool.usage_fee_for(@starts, @starts + 1.day)
    assert_equal Money.new(6_00), item_pool.usage_fee_for(@starts, @starts + 3.days)
    assert_equal Money.new(8_00), item_pool.usage_fee_for(@starts, @starts + 3.days + 1.hour)
  end

  test "usage_fee_for charges at least one period" do
    item_pool = build(:item_pool, periodic_fee: 2)

    assert_equal Money.new(2_00), item_pool.usage_fee_for(@starts, @starts + 2.hours)
    assert_equal Money.new(2_00), item_pool.usage_fee_for(@starts, @starts)
  end

  test "usage_fee_for uses the periodic fee period" do
    item_pool = build(:item_pool, periodic_fee: 5, periodic_fee_period: 7)

    assert_equal Money.new(5_00), item_pool.usage_fee_for(@starts, @starts + 7.days)
    assert_equal Money.new(10_00), item_pool.usage_fee_for(@starts, @starts + 8.days)
  end

  test "usage_fee_for combines the usage fee and periodic fee" do
    item_pool = build(:item_pool, usage_fee: 10, periodic_fee: 2)

    assert_equal Money.new(16_00), item_pool.usage_fee_for(@starts, @starts + 3.days)
  end

  test "usage_fee_for_reservation uses the reservation dates" do
    item_pool = build(:item_pool, usage_fee: 10, periodic_fee: 2)
    reservation = build(:reservation,
      started_at: Time.zone.parse("2026-10-02 00:00"),
      ended_at: Time.zone.parse("2026-10-04 12:00"))
    reservation.valid? # moves ended_at to the end of the day

    assert_equal Money.new(16_00), item_pool.usage_fee_for_reservation(reservation)
  end
end

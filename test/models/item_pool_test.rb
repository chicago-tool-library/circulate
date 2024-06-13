require "test_helper"

class ItemPoolTest < ActiveSupport::TestCase
  setup do
    @starts = 7.days.from_now.beginning_of_day
    @ends = 14.days.from_now.beginning_of_day
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

    reservation1 = create(:reservation, started_at: @starts, ended_at: @starts + 2.days)
    create(:reservation_hold, reservation: reservation1, item_pool: item_pool, quantity: 1)

    reservation2 = create(:reservation, started_at: @starts + 3.days, ended_at: @starts + 4.days)
    create(:reservation_hold, reservation: reservation2, item_pool: item_pool, quantity: 1)

    reservation3 = create(:reservation, started_at: @starts + 5.days, ended_at: @starts + 6.days)
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

    reservation1 = create(:reservation, started_at: @starts, ended_at: @starts + 4.days)
    create(:reservation_hold, reservation: reservation1, item_pool: item_pool, quantity: 1)

    reservation2 = create(:reservation, started_at: @starts + 3.days, ended_at: @starts + 4.days)
    create(:reservation_hold, reservation: reservation2, item_pool: item_pool, quantity: 1)

    reservation3 = create(:reservation, started_at: @starts + 5.days, ended_at: @starts + 6.days)
    create(:reservation_hold, reservation: reservation3, item_pool: item_pool, quantity: 1)

    assert_equal 1, reservable_item.item_pool.max_available_between(@starts, @ends)
  end
end

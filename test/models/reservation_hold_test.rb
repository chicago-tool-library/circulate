require "test_helper"

class ReservationHoldTest < ActiveSupport::TestCase
  test "prevents deletion with a dependent reservation hold" do
    reservable_item = create(:reservable_item)
    reservation_hold = create(:reservation_hold, item_pool: reservable_item.item_pool)

    assert_equal reservation_hold.quantity, 1

    create(:reservation_loan, reservation: reservation_hold.reservation, reservation_hold:, reservable_item:)

    assert_raises ActiveRecord::InvalidForeignKey do
      reservation_hold.destroy
    end
  end

  test "prevents reducing quantity beyond what is relied on by loans" do
    reservable_items = [create(:reservable_item)]
    reservable_items += 4.times.map do
      create(:reservable_item, item_pool: reservable_items.first.item_pool)
    end
    reservation_hold = create(:reservation_hold, item_pool: reservable_items.first.item_pool, quantity: 4)

    assert_equal reservation_hold.quantity, 4

    3.times do |i|
      create(:reservation_loan,
        reservation: reservation_hold.reservation,
        reservable_item: reservable_items[i],
        reservation_hold:)
    end

    reservation_hold.quantity = 2
    refute reservation_hold.valid?
    assert_equal reservation_hold.errors[:quantity], ["3 are required by existing loans"]
  end

  test "prevents reducing quantity beyond what is relied on by loans on unnumbered items" do
    item_pool = create(:item_pool, :unnumbered, unnumbered_count: 5)
    reservation_hold = create(:reservation_hold, item_pool: item_pool, quantity: 4)

    assert_equal reservation_hold.quantity, 4

    create(:reservation_loan,
      reservation: reservation_hold.reservation,
      quantity: 3,
      reservation_hold:)

    reservation_hold.quantity = 2
    refute reservation_hold.valid?
    assert_equal reservation_hold.errors[:quantity], ["3 are required by existing loans"]
  end

  test "usage_fee charges the item pool's fee for each held item" do
    item_pool = build(:item_pool, usage_fee: 10, periodic_fee: 2)
    reservation_hold = build(:reservation_hold, item_pool:, quantity: 3,
      started_at: Time.zone.parse("2026-10-02 00:00"), ended_at: Time.zone.parse("2026-10-05 00:00"))

    assert_equal Money.new(48_00), reservation_hold.usage_fee
  end

  test "usage_fee is zero when the item pool has no fee" do
    reservation_hold = build(:reservation_hold, quantity: 2,
      started_at: Time.zone.parse("2026-10-02 00:00"), ended_at: Time.zone.parse("2026-10-05 00:00"))

    assert_equal Money.new(0), reservation_hold.usage_fee
  end
end

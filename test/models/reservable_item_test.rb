require "test_helper"

class ReservableItemTest < ActiveSupport::TestCase
  test "delegates usage fees to its item pool" do
    item_pool = build(:item_pool, usage_fee: 10, periodic_fee: 2, periodic_fee_period: 7)
    reservable_item = build(:reservable_item, item_pool:)
    starts = Time.zone.parse("2026-10-02 00:00")

    assert reservable_item.usage_fee?
    assert_equal Money.new(10_00), reservable_item.usage_fee
    assert_equal Money.new(14_00), reservable_item.usage_fee_for(starts, starts + 14.days)
  end

  test "has no usage fee when its item pool has none" do
    refute build(:reservable_item).usage_fee?
  end
end

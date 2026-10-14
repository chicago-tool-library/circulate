require "test_helper"

class ReservableItemTest < ActiveSupport::TestCase
  test "assigned numbers skip past numbers used by item pools" do
    create(:item_pool, :unnumbered, number: 100)
    reservable_item = create(:reservable_item)

    assert_equal 101, reservable_item.number
  end

  test "can't use a number used by an item pool" do
    item_pool = create(:item_pool, :unnumbered)
    reservable_item = build(:reservable_item, number: item_pool.number)

    refute reservable_item.valid?
    assert_includes reservable_item.errors[:number], "is already used by an item pool"
  end
end

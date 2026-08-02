require "test_helper"

class ItemBorrowStatusTest < ActiveSupport::TestCase
  test "a uniquely numbered item with no loans or holds is available" do
    item = create(:item)

    assert_equal "available", item.borrow_status
  end

  test "a uniquely numbered item on an exclusive loan is checked out" do
    item = create(:item)
    create(:loan, item: item)

    assert_equal "checked_out", item.reload.borrow_status
  end

  test "a uniquely numbered item on a past due loan is overdue" do
    item = create(:item)
    create(:overdue_loan, item: item)

    assert_equal "overdue", item.reload.borrow_status
  end

  test "a uniquely numbered item with an active hold is on hold" do
    item = create(:item)
    create(:hold, item: item)

    assert_equal "on_hold", item.reload.borrow_status
  end

  test "an item that is checked out and on hold is checked out" do
    item = create(:item)
    create(:loan, item: item)
    create(:hold, item: item)

    assert_equal "checked_out", item.reload.borrow_status
  end

  test "an unnumbered item is available even when loaned out or on hold" do
    item = create(:uncounted_item)
    create(:nonexclusive_loan, item: item)
    create(:hold, item: item)

    assert_equal "available", item.reload.borrow_status
  end

  test "an item out of circulation with no loans is still available" do
    Item.statuses.each_key do |status|
      attributes = {status: status}
      attributes[:retired_reason] = Item.retired_reasons[:broken] if status == "retired"

      assert_equal "available", create(:item, **attributes).borrow_status,
        "expected #{status} item to be available"
    end
  end

  test "an item stays checked out when it leaves circulation" do
    item = create(:item)
    create(:loan, item: item)

    Item.statuses.each_key do |status|
      item.update_columns(status: status)

      assert_equal "checked_out", item.reload.borrow_status,
        "expected #{status} item to be checked out"
    end
  end

  test "borrow status name is the display name for the status" do
    item = create(:item)
    create(:hold, item: item)

    assert_equal "On Hold", item.reload.borrow_status_name
  end
end

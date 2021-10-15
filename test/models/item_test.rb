require "test_helper"

class ItemTest < ActiveSupport::TestCase
  include Lending

  test "assigns a number" do
    borrow_policy = create(:borrow_policy)
    item = build(:item, number: nil, borrow_policy: borrow_policy)
    item.save!

    assert item.number
  end

  test "it has a due_on date" do
    loan = create(:loan, due_at: Date.tomorrow.end_of_day)
    loan.item.reload
    assert Date.tomorrow, loan.item.due_on
  end

  test "it is not available" do
    loan = create(:loan)
    loan.item.reload
    refute loan.item.available?
  end

  test "it is available" do
    assert create(:item).available?
  end

  test "validations" do
    item = Item.new(status: nil)

    refute item.valid?

    assert_equal ["can't be blank"], item.errors[:name]
    assert_equal ["is not included in the list"], item.errors[:status]
  end

  test "strips whitespace before validating" do
    item = Item.new(name: " name ", brand: " brand ", size: " 12v", model: "123 ",
      serial: " a bc", strength: " heavy")

    item.valid?

    assert_equal "name", item.name
    assert_equal "brand", item.brand
    assert_equal "12v", item.size
    assert_equal "123", item.model
    assert_equal "a bc", item.serial
    assert_equal "heavy", item.strength
  end

  test "adding a single category is saved in the audit history" do
    @item = create(:complete_item)
    @category = create(:category)

    @item.categories << @category
    @item.save!

    assert_equal @category.id, @item.audits.last.audited_changes["category_ids"].flatten.first
  end

  test "updating it without changing categories doesn't add existing categories to audit history" do
    @item = create(:complete_item)
    @category = create(:category)

    # add initial category
    @item.categories << @category
    @item.save!

    # update property that isn't category
    @item.update!(name: "something different")

    assert_equal [], @item.audits.last.audited_changes["category_ids"].first
  end

  test "it has two items without images" do
    image = File.open(Rails.root.join("test", "fixtures", "files", "tool-image.jpg"))
    items = create_list(:item, 3)
    item = items.first
    item.image.attach(io: image, filename: "tool-image.jpg")

    assert_equal 2, Item.without_attached_image.count
  end

  test "can delete an item with a renewed loan" do
    item = create(:item)
    loan = create(:loan, item: item)
    renew_loan(loan)

    assert item.destroy
  end

  test "can delete an item with an active loan" do
    item = create(:item)
    create(:loan, item: item)

    assert item.destroy
  end

  test "can delete an item with a hold" do
    item = create(:item)
    create(:hold, item: item)

    assert item.destroy
  end

  test "can delete an item with an attachment" do
    item = create(:item)
    create(:item_attachment, item: item, creator: create(:user))
    create(:hold, item: item)

    assert item.destroy
  end

  test "has a next_hold" do
    item = create(:item)
    hold = create(:hold, item: item, created_at: 2.days.ago)
    create(:hold, item: item, created_at: 1.day.ago)

    assert_equal hold, item.next_hold
  end

  test "next_hold ignores inactive holds" do
    item = create(:item)
    create(:ended_hold, item: item)
    create(:expired_hold, item: item)

    refute item.next_hold
  end

  test "clears holds when changing to an inactive status" do
    item = create(:item)
    create(:started_hold, item: item)

    item.update!(status: Item.statuses[:pending])
    assert_equal item.active_holds.count, 1

    item.update!(status: Item.statuses[:maintenance])
    assert_equal item.active_holds.count, 0
  end

  test ".without_any_holds" do
    item_without_hold_1 = create(:item)
    item_without_hold_2 = create(:item)
    item_with_hold = create(:item)
    create(:hold, item: item_with_hold)

    query = Item.without_any_holds
    expected_result = [item_without_hold_1, item_without_hold_2]
    assert_equal query.sort, expected_result.sort
  end

  test ".with_active_holds" do
    freeze_time do
      create(:expired_hold)
      create(:ended_hold)
      started_hold = create(:started_hold)

      query = Item.with_active_holds
      expected_result = [started_hold.item]
      assert_equal query.sort, expected_result.sort
    end
  end

  test ".not_active" do
    create(:item, status: :active)
    maintenance_item = create(:item, status: :maintenance)
    pending_item = create(:item, status: :pending)
    retired_item = create(:item, status: :retired)

    query = Item.not_active
    expected_result = [maintenance_item, pending_item, retired_item]

    assert_equal query.sort, expected_result.sort
  end

  test ".with_uniquely_numbered_borrow_policy" do
    create(:item, borrow_policy: borrow_policy, name: "screwdriver")
    create(:unnumbered_borrow_policy)
    table_saw = create(:item, name: "table saw")
    sander = create(:item, name: "sander")

    query = Item.with_uniquely_numbered_borrow_policy
    expected_result = [table_saw, sander]
    assert_equal query.sort, expected_result.sort
  end
end

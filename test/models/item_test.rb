require "test_helper"

class ItemTest < ActiveSupport::TestCase
  include Lending

  test "assigns a number" do
    borrow_policy = create(:borrow_policy)
    item = build(:item, number: nil, borrow_policy: borrow_policy)
    item.save!

    assert item.number
  end

  test "assigns the next available for B tools" do
    create(:item, number: 999)

    borrow_policy = create(:borrow_policy, code: "B")
    item = build(:item, number: nil, borrow_policy: borrow_policy)
    item.save!

    assert_equal 1000, item.number
  end

  test "assigns the next available number for A tools" do
    create(:item, number: 999)

    borrow_policy = create(:borrow_policy, code: "A")
    item = build(:item, number: nil, borrow_policy: borrow_policy)
    item.save!

    assert_equal 1000, item.number
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
    image = Rails.root.join("test/fixtures/files/tool-image.jpg").open
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

  test "is holdable when active and has holds enabled" do
    item = create(:item, status: Item.statuses[:active], holds_enabled: true)
    assert item.holdable?
  end

  test "is not holdable when holds are disabled" do
    item = create(:item, status: Item.statuses[:active], holds_enabled: false)
    refute item.holdable?
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

  test "clears holds and appointments when changing to an inactive status" do
    item = create(:item)
    hold = create(:started_hold, item: item)
    member = create(:member)
    create(:appointment, member: member, starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours, holds: [hold])

    item.update!(status: Item.statuses[:pending])
    assert_equal item.active_holds.count, 1

    item.update!(status: Item.statuses[:maintenance])
    assert_equal item.active_holds.count, 1
    assert_equal member.appointments.count, 0

    item.update!(status: Item.statuses[:retired], retired_reason: Item.retired_reasons[:broken])
    assert_equal item.active_holds.count, 0
    assert_equal member.appointments.count, 0
  end

  test "clears next hold when changed to maintenance" do
    item = create(:item)
    hold = create(:started_hold, item: item)

    item.update!(status: Item.statuses[:maintenance])
    assert_nil hold.reload.started_at
  end

  test "the for_category scope returns all items for that category" do
    category1 = create(:category)
    category2 = create(:category)

    item1 = create(:item, categories: [category1])
    item2 = create(:item, categories: [category1, category2])
    item3 = create(:item)

    scope_for_category1 = Item.for_category(category1)
    scope_for_category2 = Item.for_category(category2)

    assert_includes(scope_for_category1, item1)
    assert_includes(scope_for_category1, item2)
    assert_not_includes(scope_for_category1, item3)

    assert_includes(scope_for_category2, item2)
    assert_not_includes(scope_for_category2, item1)
    assert_not_includes(scope_for_category2, item3)
  end

  test "the for_category scope returns all items for child categories" do
    parent = create(:category)
    child = create(:category, parent: parent)
    grandchild = create(:category, parent: child)

    item1 = create(:item, categories: [parent])
    item2 = create(:item, categories: [child])
    item3 = create(:item, categories: [grandchild])
    item4 = create(:item)

    scope_for_parent = Item.for_category(parent)

    assert_includes(scope_for_parent, item1)
    assert_includes(scope_for_parent, item2)
    assert_includes(scope_for_parent, item3)
    assert_not_includes(scope_for_parent, item4)

    scope_for_child = Item.for_category(child)

    assert_not_includes(scope_for_child, item1)
    assert_includes(scope_for_child, item2)
    assert_includes(scope_for_child, item3)
    assert_not_includes(scope_for_child, item4)

    scope_for_grandchild = Item.for_category(grandchild)

    assert_not_includes(scope_for_grandchild, item1)
    assert_not_includes(scope_for_grandchild, item2)
    assert_includes(scope_for_grandchild, item3)
    assert_not_includes(scope_for_grandchild, item4)
  end

  test "the for_category scope returns unique items" do
    parent = create(:category)
    child = create(:category, parent: parent)
    grandchild = create(:category, parent: child)

    item1 = create(:item, categories: [parent, child])
    item2 = create(:item, categories: [child, grandchild])
    item3 = create(:item, categories: [parent, child, grandchild])

    scope_for_parent = Item.for_category(parent)

    assert_includes(scope_for_parent, item1)
    assert_includes(scope_for_parent, item2)
    assert_includes(scope_for_parent, item3)
    assert_equal 3, scope_for_parent.count

    scope_for_child = Item.for_category(child)

    assert_includes(scope_for_child, item1)
    assert_includes(scope_for_child, item2)
    assert_includes(scope_for_child, item3)
    assert_equal 3, scope_for_child.count

    scope_for_grandchild = Item.for_category(grandchild)

    assert_includes(scope_for_grandchild, item2)
    assert_includes(scope_for_grandchild, item3)
    assert_equal 2, scope_for_grandchild.count
  end

  test "sets itself to retired when decrementing quantity to zero" do
    borrow_policy = create(:borrow_policy, consumable: true, uniquely_numbered: false)
    item = create(:item, borrow_policy: borrow_policy, quantity: 1)

    assert_equal "active", item.status

    item.decrement_quantity

    assert_equal "retired", item.status
    assert_equal 0, item.quantity
  end

  test "sets itself to active when quantity is restored" do
    borrow_policy = create(:borrow_policy, consumable: true, uniquely_numbered: false)
    item = create(:item, :retired, borrow_policy: borrow_policy, quantity: 0)

    assert_equal "retired", item.status

    item.increment_quantity

    assert_equal "active", item.status
    assert_equal 1, item.quantity
  end

  test "requires a value for quantity with a consumable borrow policy" do
    borrow_policy = create(:consumable_borrow_policy)
    item = build(:item, borrow_policy: borrow_policy)

    refute item.valid?
    assert_equal ["is not a number"], item.errors[:quantity]
  end

  test "the available_now scope returns items without active loans or holds" do
    item_with_hold = create(:item)
    create(:hold, item: item_with_hold)

    assert_not_includes(Item.available_now, item_with_hold)

    item_with_expired_hold = create(:item)
    create(:expired_hold, item: item_with_expired_hold)

    assert_includes(Item.available_now, item_with_expired_hold)

    item_with_loan = create(:item)
    create(:loan, item: item_with_loan)

    assert_not_includes(Item.available_now, item_with_loan)

    item_in_maintenance = create(:item, status: Item.statuses[:maintenance])

    assert_not_includes(Item.available_now, item_in_maintenance)
  end

  test "#accessories_text returns all of the accessories as a single string" do
    random_value = rand(100).to_s
    item = build(:item, accessories: ["foo", "bar", random_value])

    assert_equal "foo\nbar\n#{random_value}", item.accessories_text
  end

  test "#accessories_text= assigns accessories to an array based on the given string" do
    random_value = rand(100).to_s
    item = build(:item)

    item.accessories_text = "foo\n  bar  \n   #{random_value}"

    assert_equal ["foo", "bar", random_value], item.accessories
  end

  test "#accessories_text= assigns accessories to an empty array when given nil or a blank string" do
    item = build(:item)

    item.accessories_text = "    "
    assert_equal [], item.accessories

    item.accessories_text = nil
    assert_equal [], item.accessories
  end

  test "validates retired_reason when set to retired" do
    item = create(:item)
    item.status = "retired"

    refute item.valid?
    assert_equal item.errors[:retired_reason], ["is not included in the list"]
  end
end

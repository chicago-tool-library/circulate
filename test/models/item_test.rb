require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test "assigns a number" do
    item = Item.new(items(:complete).attributes.except("id", "number"))
    item.save!

    assert item.number
  end

  test "it has a due_on date" do
    item = items(:complete)
    Loan.create!(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day)

    assert Date.tomorrow, item.due_on
  end

  test "it is not available" do
    refute items(:checked_out).available?
  end

  test "it is available" do
    assert items(:complete).available?
  end

  test "validations" do
    item = Item.new(status: nil)

    refute item.valid?

    assert_equal ["can't be blank"], item.errors[:name]
    assert_equal ["is not included in the list"], item.errors[:status]
  end
end

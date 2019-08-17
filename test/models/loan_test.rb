require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "an item can only have a single active loan" do
    item = items(:complete)
    Loan.create!(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day, uniquely_numbered: true)
    loan = Loan.new(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day, uniquely_numbered: true)

    refute loan.save
    assert_equal ["is already on loan"], loan.errors[:item_id]
  end

  test "an item can only have a single numbered active loan enforced by the index" do
    item = items(:complete)
    Loan.create!(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day, uniquely_numbered: true)
    loan = Loan.new(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day, uniquely_numbered: true)

    assert_raises ActiveRecord::RecordNotUnique do
      loan.save(validate: false)
    end
  end

  test "an uncountable item can have multiple active loans" do
    item = items(:complete)
    2.times do
      Loan.create!(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day, uniquely_numbered: false)
    end
  end

  test "can update an active loan" do
    loan = loans(:active)
    loan.due_at = Date.today.end_of_day
    loan.save!
  end

  %i[pending maintenance retired].each do |status|
    test "is invalid with an item with #{status} status" do
      item = items(status)
      loan = Loan.new(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day)

      refute loan.save
      assert_equal ["is not available to loan"], loan.errors[:item_id]
    end
  end

  test "knows if it is a renewal" do
    loan = create(:loan, renewal_count: 0)
    refute loan.renewal?

    renewal = create(:loan, renewal_count: 1)
    assert renewal.renewal?
  end
end

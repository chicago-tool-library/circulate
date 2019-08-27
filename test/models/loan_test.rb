require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "an item can only have a single active loan" do
    item = create(:item)
    first_loan = create(:loan, item: item)
    loan = build(:loan, item: item)

    refute loan.save
    assert_equal ["is already on loan"], loan.errors[:item_id]
  end

  test "an item can only have a single numbered active loan enforced by the index" do
    item = create(:item)
    first_loan = create(:loan, item: item)
    loan = build(:loan, item: item)

    assert_raises ActiveRecord::RecordNotUnique do
      loan.save(validate: false)
    end
  end

  test "an uncountable item can have multiple active loans" do
    item = create(:item)
    2.times do
      create(:loan, item: item, uniquely_numbered: false)
    end
  end

  test "can update an active loan" do
    loan = create(:loan)
    loan.due_at = Date.today.end_of_day
    loan.save!
  end

  %i[pending maintenance retired].each do |status|
    test "is invalid with an item with #{status} status" do
      item = create(:item, status: status)
      loan = build(:loan, item: item, due_at: Date.tomorrow.end_of_day)

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

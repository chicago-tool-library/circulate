require 'test_helper'

class LoanTest < ActiveSupport::TestCase
  test "an item can only have a single active loan" do
    item = items(:complete)
    Loan.create!(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day)
    loan = Loan.new(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day)

    refute loan.save
    assert_equal ["is already on loan"], loan.errors[:item_id]
  end

  test "an item can only have a single active loan enforced by the index" do
    item = items(:complete)
    Loan.create!(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day)
    loan = Loan.new(item_id: item.id, member: members(:complete), due_at: Date.tomorrow.end_of_day)

    assert_raises ActiveRecord::RecordNotUnique do
      loan.save(validate: false)
    end
  end

  test "can update an active loan" do
    loan = loans(:active)
    loan.due_at = Date.today.end_of_day
    loan.save!
  end

end

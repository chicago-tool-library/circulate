require "test_helper"

class LendingTest < ActiveSupport::TestCase
  include Lending

  test "renews a loan" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    renewal = Loan.stub(:open_days, [0, 4]) {
      assert_difference("Loan.count") { renew_loan(loan, now: sunday) }
    }

    assert_equal item.id, renewal.item_id
    assert_equal loan.member_id, renewal.member_id
    assert_equal loan.id, renewal.initial_loan_id
    assert_equal sunday + 7.days, renewal.due_at
    assert_equal 1, renewal.renewal_count
    assert renewal.uniquely_numbered
  end

  test "renews a loan for a full period starting today" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 17.days), due_at: (sunday - 10.days), uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(loan, now: sunday)
    }

    assert_equal sunday + 7.days, renewal.due_at
  end

  test "renews a loan for a full period starting at due date" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day
    thursday = Time.utc(2020, 1, 30).end_of_day

    loan = create(:loan, item: item, created_at: (thursday - 7.days), due_at: thursday, uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(loan, now: sunday)
    }

    assert_equal thursday + 7.days, renewal.due_at
  end

  test "renews a loan due tomorrow" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    wednesday = Time.utc(2020, 1, 29).end_of_day
    thursday = Time.utc(2020, 1, 30).end_of_day

    loan = create(:loan, item: item, created_at: (thursday - 7.days), due_at: thursday)
    renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(loan, now: wednesday)
    }

    next_day = Loan.stub(:open_days, [0, 4]) {
      Loan.next_open_day(thursday + 7.days)
    }
    assert_equal next_day, renewal.due_at
  end

  test "renews a renewal" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day
    monday = Time.utc(2020, 1, 27).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    assert loan.renewable?
    renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(loan, now: sunday)
    }

    assert renewal.renewable?
    second_renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(renewal, now: monday)
    }

    assert_equal loan.id, second_renewal.initial_loan_id
    assert_equal sunday + 14.days, second_renewal.due_at
    assert_equal 2, second_renewal.renewal_count
  end

  test "can't renew past limit" do
    borrow_policy = create(:borrow_policy, duration: 7, renewal_limit: 1)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day
    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(loan, now: sunday)
    }

    refute renewal.renewable?
  end

  test "reverts a renewal" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) {
      renew_loan(loan, now: sunday)
    }

    assert_difference "Loan.count", -1 do
      undo_loan_renewal(renewal)
    end

    loan.reload
    refute loan.ended_at

    refute Loan.exists?(renewal.id)
  end

  test "reverts a renewed renewal" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) { renew_loan(loan, now: sunday) }
    second_renewal = Loan.stub(:open_days, [0, 4]) { renew_loan(renewal, now: sunday) }

    assert_difference "Loan.count", -1 do
      undo_loan_renewal(second_renewal)
    end

    renewal.reload
    refute renewal.ended_at
    assert loan.ended_at

    refute Loan.exists?(second_renewal.id)
  end

  test "returns a loan with a deleted item" do
    item = create(:item)
    loan = create(:loan, item: item)

    assert item.destroy

    loan.reload # clears item_id

    assert return_loan(loan)
  end

  test "renews a loan with a deleted item" do
    item = create(:item)
    loan = create(:loan, item: item)

    assert item.destroy

    loan.reload # clears item_id

    assert renew_loan(loan)
  end
end

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
    assert_timestamp_equal sunday + 7.days, renewal.due_at
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

    assert_timestamp_equal sunday + 7.days, renewal.due_at
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

    assert_timestamp_equal thursday + 7.days, renewal.due_at
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
    assert_timestamp_equal next_day, renewal.due_at
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
    assert_timestamp_equal sunday + 14.days, second_renewal.due_at
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

  test "updates appointment loans to point to the renewal" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    appointment = create(:appointment, member: loan.member, loans: [loan])
    appointment_loan = appointment.appointment_loans.first

    renewal = Loan.stub(:open_days, [0, 4]) {
      assert_difference("Loan.count") { renew_loan(loan, now: sunday) }
    }

    appointment.reload
    appointment_loan.reload

    assert_equal 1, appointment.appointment_loans.size
    assert_equal renewal.id, appointment_loan.loan_id
  end

  test "restores appointment loan to previous loan when reverted" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    appointment = create(:appointment, member: loan.member, loans: [loan])
    appointment_loan = appointment.appointment_loans.first

    renewal = Loan.stub(:open_days, [0, 4]) {
      assert_difference("Loan.count") { renew_loan(loan, now: sunday) }
    }

    undo_loan_renewal(renewal)

    appointment.reload
    appointment_loan.reload

    assert_equal 1, appointment.appointment_loans.size
    assert_equal loan.id, appointment_loan.loan_id
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

  test "automatically returns consumable items" do
    borrow_policy = create(:consumable_borrow_policy)
    item = create(:item, quantity: 10, borrow_policy: borrow_policy)
    member = create(:verified_member)

    loan = assert_no_difference "Audited::Audit.count" do
      create_loan(item, member)
    end
    assert loan.persisted?

    assert loan.ended_at
    assert_equal 9, item.quantity
  end

  test "restores consumable quantity when undoing a loan" do
    borrow_policy = create(:consumable_borrow_policy)
    item = create(:item, quantity: 10, borrow_policy: borrow_policy)
    member = create(:verified_member)

    loan = create_loan(item, member)
    assert_equal 9, item.quantity

    assert undo_loan(loan)
    assert_equal 10, item.quantity
  end

  test "destroy loan after undoing" do
    borrow_policy = create(:default_borrow_policy)
    item = create(:item, quantity: 1, borrow_policy: borrow_policy)
    member = create(:verified_member)

    loan = create_loan(item, member)
    assert !member.checked_out_loans.empty?

    assert undo_loan(loan)
    assert member.checked_out_loans.empty?
  end

  test "can't loan item in maintenance" do
    item = create(:item, status: Item.statuses[:maintenance])
    member = create(:member)

    loan = create_loan(item, member)
    assert !loan.persisted?
    assert member.checked_out_loans.empty?
  end

  test "marks the item as retired when the quantity hits 0" do
    borrow_policy = create(:consumable_borrow_policy)
    item = create(:item, quantity: 1, borrow_policy: borrow_policy)
    member = create(:verified_member)

    assert_difference "Audited::Audit.count" do
      create_loan(item, member)
    end

    assert_equal 0, item.quantity
    assert_equal Item.statuses[:retired], item.status
    assert_equal "Quantity exhausted", item.audits.last.comment
  end

  test "restores consumable quantity and status when undoing a loan that exhausted the item" do
    borrow_policy = create(:consumable_borrow_policy)
    item = create(:item, quantity: 1, borrow_policy: borrow_policy)
    member = create(:verified_member)

    loan = create_loan(item, member)

    assert_difference "Audited::Audit.count" do
      assert undo_loan(loan)
    end

    assert_equal 1, item.quantity
    assert_equal Item.statuses[:active], item.status
    assert_equal "Quantity restored", item.audits.last.comment
  end
end

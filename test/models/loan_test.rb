require "test_helper"

class LoanTest < ActiveSupport::TestCase
  test "an item can only have a single active loan" do
    item = create(:item)
    create(:loan, item: item)
    loan = build(:loan, item: item)

    refute loan.save
    assert_equal ["is already on loan"], loan.errors[:item_id]
  end

  test "an item can only have a single numbered active loan enforced by the index" do
    item = create(:item)
    create(:loan, item: item)
    loan = build(:loan, item: item)

    assert_raises ActiveRecord::RecordNotUnique do
      loan.save(validate: false)
    end
  end

  test "validates an empty record" do
    refute Loan.new.valid?
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

  test "renews itself" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)

    tonight = Time.current.end_of_day
    loan = create(:loan, item: item, created_at: 7.days.ago, due_at: tonight, uniquely_numbered: true)
    renewal = loan.renew!

    assert_equal item.id, renewal.item_id
    assert_equal loan.member_id, renewal.member_id
    assert_equal loan.id, renewal.initial_loan_id
    assert_equal tonight + 7.days, renewal.due_at
    assert_equal 1, renewal.renewal_count
    assert renewal.uniquely_numbered
  end

  test "renewal policy itself for a full period starting today" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)

    tonight = Time.current.end_of_day
    loan = create(:loan, item: item, created_at: 17.days.ago, due_at: 10.days.ago.end_of_day, uniquely_numbered: true)
    renewal = loan.renew!

    assert_equal tonight + 7.days, renewal.due_at
  end

  test "renews itself for a full period starting at due date" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)

    tonight = Time.current.end_of_day
    loan = create(:loan, item: item, created_at: 3.days.ago, due_at: 4.days.since.end_of_day, uniquely_numbered: true)
    renewal = loan.renew!

    assert_equal tonight + 11.days, renewal.due_at
  end

  test "renews a loan that is due tomorrow" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)

    tomorrow = Time.current.end_of_day + 1.day
    loan = create(:loan, item: item, created_at: 7.days.ago, due_at: tomorrow)
    renewal = loan.renew!

    assert_equal Loan.next_open_day(tomorrow + 7.days), renewal.due_at
  end

  test "renews a renewal" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)

    tonight = Time.current.end_of_day
    loan = create(:loan, item: item, created_at: 7.days.ago, due_at: tonight, uniquely_numbered: true)
    first_renewal = loan.renew!
    second_renewal = first_renewal.renew!

    assert_equal loan.id, second_renewal.initial_loan_id
    assert_equal tonight + 14.days, second_renewal.due_at
    assert_equal 2, second_renewal.renewal_count
  end

  test "finds loans that were due whole weeks ago" do
    tonight = Time.current.end_of_day
    loan = create(:loan, due_at: tonight)

    yesterday = Time.current.end_of_day - 1.day
    create(:loan, due_at: yesterday)

    one_week_ago = Time.current.end_of_day - 1.week
    week_ago_loan = create(:loan, due_at: one_week_ago)

    many_weeks_ago = Time.current.end_of_day - 13.weeks
    many_weeks_ago_loan = create(:loan, due_at: many_weeks_ago)

    assert_equal [many_weeks_ago_loan.id, week_ago_loan.id, loan.id], Loan.due_whole_weeks_ago.order(due_at: :asc).pluck(:id)
  end

  test "creates loans that end on an open day" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    member = create(:verified_member_with_membership)

    now = Time.new(2020, 1, 18, 12) # saturday
    loan = Loan.lend(item, to: member, now: now)

    sunday = Time.new(2020, 1, 26).end_of_day

    assert_equal sunday, loan.due_at
  end

  test "returns the same day as the next open day" do
    sunday = Time.new(2020, 1, 26).end_of_day
    assert_equal sunday, Loan.next_open_day(sunday)

    thursday = Time.new(2020, 1, 23).end_of_day
    assert_equal thursday, Loan.next_open_day(thursday)
  end

  test "returns the next day as the next open day" do
    monday = Time.new(2020, 1, 20).end_of_day
    tuesday = Time.new(2020, 1, 21).end_of_day
    wednesday = Time.new(2020, 1, 22).end_of_day
    thursday = Time.new(2020, 1, 23).end_of_day

    assert_equal thursday, Loan.next_open_day(monday)
    assert_equal thursday, Loan.next_open_day(tuesday)
    assert_equal thursday, Loan.next_open_day(wednesday)

    friday = Time.new(2020, 1, 24).end_of_day
    saturday = Time.new(2020, 1, 25).end_of_day
    sunday = Time.new(2020, 1, 26).end_of_day

    assert_equal sunday, Loan.next_open_day(friday)
    assert_equal sunday, Loan.next_open_day(saturday)
  end
end

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
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    renewal = Loan.stub(:open_days, [0, 4]) {
      assert_difference("Loan.count") { loan.renew!(sunday) }
    }

    assert_equal item.id, renewal.item_id
    assert_equal loan.member_id, renewal.member_id
    assert_equal loan.id, renewal.initial_loan_id
    assert_equal sunday + 7.days, renewal.due_at
    assert_equal 1, renewal.renewal_count
    assert renewal.uniquely_numbered
  end

  test "renews itself for a full period starting today" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 17.days), due_at: (sunday - 10.days), uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) {
      loan.renew!(sunday)
    }

    assert_equal sunday + 7.days, renewal.due_at
  end

  test "renews itself for a full period starting at due date" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day
    thursday = Time.utc(2020, 1, 30).end_of_day

    loan = create(:loan, item: item, created_at: (thursday - 7.days), due_at: thursday, uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) {
      loan.renew!(sunday)
    }

    assert_equal thursday + 7.days, renewal.due_at
  end

  test "renews a loan that is due tomorrow" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    wednesday = Time.utc(2020, 1, 29).end_of_day
    thursday = Time.utc(2020, 1, 30).end_of_day

    loan = create(:loan, item: item, created_at: (thursday - 7.days), due_at: thursday)
    renewal = Loan.stub(:open_days, [0, 4]) {
      loan.renew!(wednesday)
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
      loan.renew!(sunday)
    }

    assert loan.renewable?
    second_renewal = Loan.stub(:open_days, [0, 4]) {
      renewal.renew!(monday)
    }

    assert_equal loan.id, second_renewal.initial_loan_id
    assert_equal sunday + 14.days, second_renewal.due_at
    assert_equal 2, second_renewal.renewal_count
  end

  test "isn't renewable again" do
    borrow_policy = create(:borrow_policy, duration: 7, renewal_limit: 1)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day
    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)

    renewal = Loan.stub(:open_days, [0, 4]) {
      loan.renew!(sunday)
    }

    refute renewal.renewable?
  end

  test "reverts a renewal" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    sunday = Time.utc(2020, 1, 26).end_of_day

    loan = create(:loan, item: item, created_at: (sunday - 7.days), due_at: sunday, uniquely_numbered: true)
    renewal = Loan.stub(:open_days, [0, 4]) {
      loan.renew!(sunday)
    }

    assert_difference "Loan.count", -1 do
      renewal.undo_renewal!
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
    renewal = Loan.stub(:open_days, [0, 4]) { loan.renew!(sunday) }
    second_renewal = Loan.stub(:open_days, [0, 4]) { renewal.renew!(sunday) }

    assert_difference "Loan.count", -1 do
      second_renewal.undo_renewal!
    end

    renewal.reload
    refute renewal.ended_at
    assert loan.ended_at

    refute Loan.exists?(second_renewal.id)
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

  test "does not find loans that are due in the future" do
    in_one_week = Time.current.end_of_day + 1.week
    create(:loan, due_at: in_one_week)

    assert_equal [], Loan.due_whole_weeks_ago.order(due_at: :asc).pluck(:id)
  end

  test "creates loans that end on an open day" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)
    member = create(:verified_member_with_membership)

    now = Time.utc(2020, 1, 18, 12) # saturday
    loan = Loan.stub(:open_days, [0, 4]) {
      Loan.lend(item, to: member, now: now)
    }

    sunday = Time.utc(2020, 1, 26).end_of_day

    assert_equal sunday, loan.due_at
  end

  test "returns the same day as the next open day" do
    Loan.stub(:open_days, [0, 4]) do
      sunday = Time.utc(2020, 1, 26).end_of_day
      assert_equal sunday, Loan.next_open_day(sunday)

      thursday = Time.utc(2020, 1, 23).end_of_day
      assert_equal thursday, Loan.next_open_day(thursday)
    end
  end

  test "returns the next day as the next open day" do
    monday = Time.utc(2020, 1, 20).end_of_day
    tuesday = Time.utc(2020, 1, 21).end_of_day
    wednesday = Time.utc(2020, 1, 22).end_of_day
    thursday = Time.utc(2020, 1, 23).end_of_day

    Loan.stub(:open_days, [0, 4]) do
      assert_equal thursday, Loan.next_open_day(monday)
      assert_equal thursday, Loan.next_open_day(tuesday)
      assert_equal thursday, Loan.next_open_day(wednesday)
    end

    friday = Time.utc(2020, 1, 24).end_of_day
    saturday = Time.utc(2020, 1, 25).end_of_day
    sunday = Time.utc(2020, 1, 26).end_of_day

    Loan.stub(:open_days, [0, 4]) do
      assert_equal sunday, Loan.next_open_day(friday)
      assert_equal sunday, Loan.next_open_day(saturday)
    end
  end

  test "status is checked-out when due_at is in the future" do
    loan = build(:loan, due_at: 7.days.from_now)

    assert_equal "checked-out", loan.status
  end

  test "status is overdue when due_at has past" do
    loan = build(:loan, due_at: 2.days.ago)

    assert_equal "overdue", loan.status
  end
end

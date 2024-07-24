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

  test "is member_renewable if borrow_policy allows member renewal is within original loan duration and has not exceeded limit" do
    borrow_policy = build(:member_renewable_borrow_policy)
    item = build(:item, borrow_policy: borrow_policy)
    loan = build(:loan, item: item)

    assert loan.member_renewable?
  end

  test "is not member_renewable if renewal count exceeds limit" do
    borrow_policy = build(:member_renewable_borrow_policy)
    item = build(:item, borrow_policy: borrow_policy)
    loan = build(:loan, item: item, renewal_count: borrow_policy.renewal_limit)

    refute loan.member_renewable?
  end

  test "is not member renewable if borrow_policy does not allow member renewals" do
    borrow_policy = build(:borrow_policy, member_renewable: false)
    item = build(:item, borrow_policy: borrow_policy)
    loan = build(:loan, item: item)

    refute loan.member_renewable?
  end

  test "is not member_renewable if loan has end date" do
    borrow_policy = create(:member_renewable_borrow_policy)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, item: item, created_at: Time.current, ended_at: Time.current)

    refute loan.member_renewable?
  end

  test "is member_renewal_requestable without a renewable borrow policy" do
    borrow_policy = create(:borrow_policy, member_renewable: false)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, item: item)

    assert loan.member_renewal_requestable?
  end

  test "is not member_renewal_requestable if there are active holds" do
    borrow_policy = create(:borrow_policy, member_renewable: false)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, item: item)
    create(:hold, item: item, member: loan.member, ended_at: nil)
    item.reload
    loan.reload

    refute loan.member_renewal_requestable?
  end

  test "is not member_renewal_requestable if there are pending or rejected requests" do
    borrow_policy = create(:borrow_policy, member_renewable: false)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, item: item)
    create(:renewal_request, loan: loan, status: RenewalRequest.statuses[:rejected])
    loan.reload

    refute loan.member_renewal_requestable?
  end

  test "is member_renewal_requestable until the end of the day a loan expires" do
    loan_ends = Date.new(2021, 0o5, 27, 4).to_time
    borrow_policy = create(:borrow_policy, member_renewable: false)
    item = create(:item, borrow_policy: borrow_policy)
    loan = create(:loan, item: item, due_at: loan_ends)

    travel_to loan_ends + 1.minute do
      assert loan.member_renewal_requestable?
    end

    travel_to loan_ends + 1.day do
      assert loan.member_renewal_requestable?
    end
  end

  test "#upcoming_appointment should call its member.upcoming_appointment_of with itself" do
    member_double = Minitest::Mock.new
    loan = create(:loan)
    loan.stub :member, member_double do
      member_double.expect(:upcoming_appointment_of, nil, [loan])
      loan.upcoming_appointment
    end
  end

  test "scope #overdue contains only overdue loans" do
    create(:ended_loan) # ignored
    overdue_loans = create_list(:overdue_loan, 3)
    create(:loan) # active loan - ignored

    query = Loan.all.overdue

    assert_equal overdue_loans.size, query.count
    assert_equal overdue_loans, query.order(id: :asc)
  end
end

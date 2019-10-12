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

  test "renews a loan that is due tomorrow" do
    borrow_policy = create(:borrow_policy, duration: 7)
    item = create(:item, borrow_policy: borrow_policy)

    tomorrow = Time.current.end_of_day + 1.day
    loan = create(:loan, item: item, created_at: 7.days.ago, due_at: tomorrow)
    renewal = loan.renew!

    assert_equal tomorrow + 7.days, renewal.due_at
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
end

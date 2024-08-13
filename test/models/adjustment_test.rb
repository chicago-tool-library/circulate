require "test_helper"

class AdjustmentTest < ActiveSupport::TestCase
  test "factory definitions" do
    assert_nothing_raised do
      create(:fine_adjustment)
      create(:membership_adjustment)
      create(:donation_adjustment)
      create(:cash_payment_adjustment)
      create(:square_payment_adjustment)
    end
  end

  test "records member paying account balance" do
    adjustment = create(:fine_adjustment, amount_cents: -1000)
    member = adjustment.member

    assert_equal Money.new(-1000), member.account_balance
    adjustments = Adjustment.record_member_payment(member, Money.new(1000), "cash")

    assert_equal 0, member.account_balance

    assert_equal 1, adjustments.size
    assert_equal "payment", adjustments.first.kind
    assert_equal 1000, adjustments.first.amount_cents
    assert_equal "cash", adjustments.first.payment_source
  end

  test "records member paying over account balance" do
    adjustment = create(:fine_adjustment, amount_cents: -1000)
    member = adjustment.member

    adjustments = Adjustment.record_member_payment(member, Money.new(1500), "cash")

    assert_equal 0, member.account_balance

    assert_equal 2, adjustments.size
    assert adjustments.first.donation?
    assert_equal(-500, adjustments.first.amount_cents)
    assert_nil adjustments.first.payment_source

    assert adjustments.second.payment?
    assert_equal 1500, adjustments.second.amount_cents
    assert_equal "cash", adjustments.second.payment_source
  end

  test "records member paying under account balance" do
    adjustment = create(:fine_adjustment, amount_cents: -1000)
    member = adjustment.member

    assert_equal Money.new(-1000), member.account_balance
    adjustments = Adjustment.record_member_payment(member, Money.new(500), "cash")

    assert_equal Money.new(-500), member.account_balance

    assert_equal 1, adjustments.size
    assert_equal "payment", adjustments.first.kind
    assert_equal 500, adjustments.first.amount_cents
    assert_equal "cash", adjustments.first.payment_source
  end

  # test "requires a square_transaction_id when source is square" do
  #   adjustment = build(:adjustment, payment_source: "square")

  #   refute adjustment.valid?

  #   assert_equal ["can't be blank"], adjustment.errors[:square_transaction_id]
  # end
end

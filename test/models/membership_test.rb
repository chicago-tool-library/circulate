require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    ActsAsTenant.current_tenant = create(:library)
  end

  teardown do
    ActsAsTenant.current_tenant = nil
  end

  test "creates a membership for a member" do
    member = create(:member)
    now = Time.current.to_date

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 0) {
        Membership.create_for_member(member, now: now)
      }
    }

    assert_equal member, membership.member
    assert_equal now, membership.started_on
    assert_equal now + 364.days, membership.ended_on
  end

  test "creates a membership for a member with a cash payment" do
    member = create(:member)
    now = Time.current.to_date
    amount = Money.new(12.34)

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 2) {
        Membership.create_for_member(member, now: now, amount: amount, source: "cash")
      }
    }

    membership_adjustment = membership.adjustment
    assert_equal amount * -1, membership_adjustment.amount
    assert_equal "membership", membership_adjustment.kind
    assert_nil membership_adjustment.payment_source
    assert_equal membership, membership_adjustment.adjustable

    payment_adjustment = member.adjustments.where.not(id: membership_adjustment.id).first
    assert_equal amount, payment_adjustment.amount
    assert_equal "payment", payment_adjustment.kind
    assert_equal "cash", payment_adjustment.payment_source
    assert_nil payment_adjustment.square_transaction_id
    assert_nil payment_adjustment.adjustable
  end

  test "creates a membership for a member with a square payment" do
    member = create(:member)
    now = Time.current.to_date
    amount = Money.new(12.34)

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 2) {
        Membership.create_for_member(member, now: now, amount: amount, source: "square", square_transaction_id: "sq_abcd")
      }
    }

    assert_equal member, membership.member
    assert_equal now, membership.started_on
    assert_equal now + 364.days, membership.ended_on

    membership_adjustment = membership.adjustment
    assert_equal amount * -1, membership_adjustment.amount
    assert_equal "membership", membership_adjustment.kind
    assert_nil membership_adjustment.payment_source
    assert_equal membership, membership_adjustment.adjustable

    payment_adjustment = member.adjustments.where.not(id: membership_adjustment.id).first
    assert_equal amount, payment_adjustment.amount
    assert_equal "payment", payment_adjustment.kind
    assert_equal "square", payment_adjustment.payment_source
    assert_equal "sq_abcd", payment_adjustment.square_transaction_id
    assert_nil payment_adjustment.adjustable
  end
end

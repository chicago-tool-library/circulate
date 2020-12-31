require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "creates a membership for a member" do
    member = create(:member)
    now = Time.current.beginning_of_day

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 0) {
        Membership.create_for_member(member, now: now, start_membership: true)
      }
    }

    assert_equal member, membership.member
    assert_equal now, membership.started_at
    assert_equal now + 364.days, membership.ended_on
  end

  test "creates a pending membership for a member" do
    member = create(:member)
    now = Time.current.beginning_of_day

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 0) {
        Membership.create_for_member(member, now: now)
      }
    }

    assert_equal member, membership.member
    assert_nil membership.started_at
    assert_nil membership.ended_on
  end

  test "creates a membership for a member with a cash payment" do
    member = create(:member)
    now = Time.current.beginning_of_day
    amount = Money.new(12.34)

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 2) {
        Membership.create_for_member(member, now: now, amount: amount, source: "cash", start_membership: true)
      }
    }

    assert_equal now, membership.started_at
    assert_equal now + 364.days, membership.ended_on
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

  test "creates a pending membership for a member with a cash payment" do
    member = create(:member)
    now = Time.current.beginning_of_day
    amount = Money.new(12.34)

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 2) {
        Membership.create_for_member(member, now: now, amount: amount, source: "cash")
      }
    }

    assert_nil membership.started_at
    assert_nil membership.ended_on
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
    now = Time.current.beginning_of_day
    amount = Money.new(12.34)

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 2) {
        Membership.create_for_member(member, now: now, amount: amount, start_membership: true, source: "square", square_transaction_id: "sq_abcd")
      }
    }

    assert_equal member, membership.member
    assert_equal now, membership.started_at
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

  test "creates a pending membership for a member with a square payment" do
    member = create(:member)
    now = Time.current.beginning_of_day
    amount = Money.new(12.34)

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 2) {
        Membership.create_for_member(member, now: now, amount: amount, source: "square", square_transaction_id: "sq_abcd")
      }
    }

    assert_equal member, membership.member
    assert_nil membership.started_at
    assert_nil membership.ended_on

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

  test "is pending" do
    membership = create(:pending_membership)

    assert_nil membership.started_at
    assert_nil membership.ended_on
    assert membership.pending?
    assert_equal membership, Membership.pending.first
  end

  test "prevents a member from having an overlapping later membership" do
    member = create(:member)
    membership = create(:membership, member: member)

    later_membership = build(:membership, member: member, started_at: membership.ended_on)
    refute later_membership.valid?
    assert_equal ["can't overlap with another membership"], later_membership.errors[:base]
  end

  test "prevents a member from having an overlapping earlier membership" do
    member = create(:member)
    membership = create(:membership, member: member)

    earlier_membership = build(:membership, member: member, ended_on: membership.started_at)
    refute earlier_membership.valid?
    assert_equal ["can't overlap with another membership"], earlier_membership.errors[:base]
  end

  test "allows different members to have overlapping memberships" do
    member = create(:member)
    membership = create(:membership, member: member)

    member2 = create(:member)
    create(:membership, member: member2, started_at: membership.started_at)
  end
end

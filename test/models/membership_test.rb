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
    assert_equal now + 365.days, membership.ended_at
    assert_equal "initial", membership.membership_type
  end

  test "creates a second membership for a member who already has one" do
    member = create(:member)
    Membership.create_for_member(member, now: 13.months.ago, start_membership: true)

    now = Time.current.beginning_of_day

    membership = assert_difference("Membership.count", 1) {
      assert_difference("Adjustment.count", 0) {
        Membership.create_for_member(member, now: now, start_membership: true)
      }
    }

    assert_equal "renewal", membership.membership_type
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
    assert_nil membership.ended_at
    assert_equal "initial", membership.membership_type
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
    assert_equal now + 365.days, membership.ended_at
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
    assert_nil membership.ended_at
    membership_adjustment = membership.adjustment
    assert_equal amount * -1, membership_adjustment.amount
    assert_equal "membership", membership_adjustment.kind
    assert_nil membership_adjustment.payment_source
    assert_equal membership, membership_adjustment.adjustable
    assert_equal "initial", membership.membership_type

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
    assert_equal now + 365.days, membership.ended_at

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
    assert_nil membership.ended_at

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
    assert_nil membership.ended_at
    assert membership.pending?
    assert_equal membership, Membership.pending.first
  end

  test "allows a member to have a membership that immediately follows an existing one" do
    member = create(:member)
    membership = create(:membership, member: member)

    later_membership = build(:membership, member: member, started_at: membership.ended_at)
    assert later_membership.valid?
  end

  test "prevents a member from having an overlapping later membership" do
    member = create(:member)
    membership = create(:membership, member: member)

    later_membership = build(:membership, member: member, started_at: membership.ended_at - 1.second)
    refute later_membership.valid?
    assert_equal ["can't overlap with another membership"], later_membership.errors[:base]
  end

  test "prevents a member from having an overlapping earlier membership" do
    member = create(:member)
    membership = create(:membership, member: member)

    earlier_membership = build(:membership, member: member, ended_at: membership.started_at + 1.second)
    refute earlier_membership.valid?
    assert_equal ["can't overlap with another membership"], earlier_membership.errors[:base]
  end

  test "allows different members to have overlapping memberships" do
    member = create(:member)
    membership = create(:membership, member: member)

    member2 = create(:member)
    assert_nothing_raised {
      create(:membership, member: member2, started_at: membership.started_at)
    }
  end

  test "next_start_date_for_member with a pending membership" do
    member = create(:member)
    create(:pending_membership, member: member)

    assert_nil Membership.next_start_date_for_member(member)
  end

  test "next_start_date_for_member with an existing membership" do
    member = create(:member)
    first_membership = create(:membership, member: member)

    assert_equal first_membership.ended_at, Membership.next_start_date_for_member(member)
  end

  test "next_start_date_for_member with a new member" do
    member = create(:member)
    now = Time.zone.parse("2025-11-05")

    assert_equal now, Membership.next_start_date_for_member(member, now: now)
  end
end

require 'test_helper'

class LoanSummaryTest < ActiveSupport::TestCase
  test "summarizes the state of a two loans" do
    @member = create(:member)
    @hammer = create(:item, name: "hammer")
    @drill = create(:item, name: "drill")

    create(:loan, member: @member, item: @hammer)
    create(:loan, member: @member, item: @drill)

    summaries = LoanSummary.where(member_id: @member.id)

    assert_equal 2, summaries.count
  end

  test "summarizes the state of a renewed loans" do
    @member = create(:member)
    @hammer = create(:item, name: "hammer")
    @drill = create(:item, name: "drill")
    @loom = create(:item, name: "loom")

    hammer_loan = create(:loan, member: @member, item: @hammer, created_at: 2.weeks.ago, due_at: 1.week.ago)
    hammer_renewal = hammer_loan.renew!(1.week.ago)
    drill_loan = create(:loan, member: @member, item: @drill)
    loom_loan = create(:loan, member: @member, item: @loom, created_at: 2.weeks.ago, due_at: 1.week.ago)
    loom_renewal = loom_loan.renew!(1.week.ago).return!

    summaries = LoanSummary.where(member_id: @member.id).order("initial_loan_id ASC")

    assert_equal 3, summaries.count
    hammer_summary, drill_summary, loom_summary = summaries

    assert_equal @hammer.id, hammer_summary.item_id
    assert_equal hammer_loan.id, hammer_summary.initial_loan_id
    assert_nil hammer_summary.ended_at
    assert_equal hammer_loan.created_at, hammer_summary.created_at
    assert_equal 1, hammer_summary.renewal_count

    assert_equal @drill.id, drill_summary.item_id
    assert_equal drill_loan.id, drill_summary.initial_loan_id
    assert_nil drill_summary.ended_at
    assert_equal drill_summary.created_at, drill_summary.created_at
    assert_equal 0, drill_summary.renewal_count

    assert_equal @loom.id, loom_summary.item_id
    assert_equal loom_loan.id, loom_summary.initial_loan_id
    assert_equal loom_renewal.ended_at, loom_summary.ended_at
    assert_equal loom_loan.created_at, loom_summary.created_at
    assert_equal 1, loom_summary.renewal_count
  end
end

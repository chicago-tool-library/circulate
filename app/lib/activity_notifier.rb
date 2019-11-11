class ActivityNotifier
  def initialize(now = Time.current)
    @now = now
  end

  def send_daily_loan_summaries
    members_active_today = Member.active_on(@now).pluck(:id)
    members_with_overdue_items = Member.active.joins(:loans).merge(Loan.due_whole_weeks_ago).pluck(:id)
    unique_ids = (members_active_today + members_with_overdue_items).uniq

    Member.find(unique_ids).each do |member|
      summaries = member.loan_summaries
        .active_on(@now)
        .or(member.loan_summaries.checked_out)
        .includes(item: :borrow_policy)
      MemberMailer.with(member: member, summaries: summaries, now: @now).loan_summaries.deliver
    end
  end

  def remind_pending_members
    Member.status_pending.where("created_at < ?", @now).each do |member|
      MemberMailer.with(member: member).membership_reminder.deliver
    end
  end
end

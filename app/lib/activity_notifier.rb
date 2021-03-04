class ActivityNotifier
  def initialize(now = Time.current)
    @now = now
  end

  def send_daily_loan_summaries
    members_active_today = Member.active_on(@now).pluck(:id)

    each_member(members_active_today) do |member, summaries|
      MemberMailer.with(member: member, summaries: summaries, now: @now).loan_summaries.deliver
    end
  end

  def send_overdue_notices
    members_with_overdue_items = Member.verified.joins(:loans).merge(Loan.checked_out.due_whole_weeks_ago).pluck(:id)

    each_member(members_with_overdue_items) do |member, summaries|
      MemberMailer.with(member: member, summaries: summaries, now: @now).overdue_notice.deliver
    end
  end

  def send_return_reminders
    tomorrow = @now + 1.day
    members_with_items_due_tomorrow = Member.verified.joins(:loans).merge(Loan.checked_out.due_on(tomorrow)).pluck(:id)

    each_member(members_with_items_due_tomorrow) do |member, summaries|
      MemberMailer.with(member: member, summaries: summaries, now: @now).return_reminder.deliver
    end
  end

  # TODO activate this one
  def remind_pending_members
    Member.status_pending.where("created_at < ?", @now).each do |member|
      MemberMailer.with(member: member).membership_reminder.deliver
    end
  end

  private

  def each_member(ids, &block)
    Member.find(ids).each do |member|
      summaries = member.loan_summaries
        .active_on(@now)
        .or(member.loan_summaries.includes(:renewal_requests).checked_out)
        .includes(item: :borrow_policy)
      yield member, summaries
    end
  end
end

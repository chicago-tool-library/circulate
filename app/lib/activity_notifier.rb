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
    members_with_overdue_items = Member.verified.joins(:loans).merge(Loan.checked_out.due_whole_weeks_ago(@now)).pluck(:id)

    each_member(members_with_overdue_items) do |member, summaries|
      summaries = summaries.overdue_as_of(@now.tomorrow.beginning_of_day)
      MemberMailer.with(member: member, summaries: summaries, now: @now).overdue_notice.deliver
      if FeatureFlags.sms_reminders_enabled?
        MemberTexter.new(member).overdue_notice(summaries)
      end
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

  def send_staff_daily_renewal_requests
    daily_renewal_requests = RenewalRequest.requested.where.not(loan_id: nil).where("created_at >= ?", @now.beginning_of_day.utc).includes(loan: [:item, :member])
    unless daily_renewal_requests.any?
      Rails.logger.info "no renewal requests waiting for approval"
      return
    end

    Member.joins(:user).where(users: {role: :admin}).each do |staff|
      MemberMailer.with(member: staff, renewal_requests: daily_renewal_requests).staff_daily_renewal_requests.deliver
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
    rescue RuntimeError => e
      Rails.logger.error("Error notifying member #{member.id}: #{e}")
      Appsignal.send_error(e)
    end
  end
end

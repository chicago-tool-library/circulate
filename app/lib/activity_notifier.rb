class ActivityNotifier
  def initialize(now = Time.current)
    @now = now
  end

  def send_daily_loan_summaries
    Member.active_on(@now).each do |member|
      summaries = member.loan_summaries.active_on(@now)
      MemberMailer.with(member: member, summaries: summaries).loan_summaries.deliver
    end
  end
end
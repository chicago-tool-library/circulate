class ActivityNotifier
  def initialize(now = Time.current)
    @now = now
  end

  def send_daily_loan_summaries
    Member.active_on(@now).each do |member|
      MemberMailer.with(member: member, summaries: member.loan_summaries).loan_summaries.deliver
    end
  end
end

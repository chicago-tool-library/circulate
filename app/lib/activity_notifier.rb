class ActivityNotifier
  def initialize(now = Time.current)
    @now = now
  end

  def send_daily_loan_summaries
    Member.active_on(@now).tap do |active_members|
      puts "active members: #{active_members.count}"
    end.each do |member|
      puts member.email
      summaries = member.loan_summaries.active_today(@now)
      MemberMailer.with(member: member, summaries: summaries).loan_summaries.deliver
    end
  end
end

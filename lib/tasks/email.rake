def send_emails(mails, date)
  Time.use_zone("America/Chicago") do
    now = date ? Date.iso8601(date) : Time.current.to_date
    puts "ActivityNotifier.new(#{now}).#{mails}"
    ActivityNotifier.new(now).send(mails)
  end
end

namespace :email do
  desc "Send daily loan summary emails"
  task :send_daily_loan_summaries, [:date] => :environment do |task, args|
    send_emails :send_daily_loan_summaries, args[:date]
  end

  desc "Send overdue notice emails"
  task :send_overdue_notices, [:date] => :environment do |task, args|
    send_emails :send_overdue_notices, args[:date]
  end

  desc "Send return reminder emails"
  task :send_return_reminders, [:date] => :environment do |task, args|
    send_emails :send_return_reminders, args[:date]
  end

  desc "Send reminders to pending members older than 1 month"
  task :send_pending_member_reminders, [:date] => :environment do |task, args|
    send_emails :remind_pending_members, args[:date]
  end

  desc "Send membership renewal reminder emails"
  task send_membership_renewal_reminders: :environment do
    Membership.expiring_before(Date.new(2021, 2, 1)).each do |membership|
      member = membership.member
      amount = member.last_membership&.amount || Money.new(0)
      MemberMailer.with(member: member, amount: amount).membership_renewal_reminder.deliver_now
    end
  end

  desc "Send staff renewal request summary emails"
  task :send_staff_daily_renewal_requests, [:date] => :environment do |task, args|
    send_emails :send_staff_daily_renewal_requests, args[:date]
  end
end

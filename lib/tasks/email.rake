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
end

desc "Send daily loan summary emails"
task :send_daily_loan_summaries, [:date] => :environment do |task, args|
  Time.use_zone("America/Chicago") do
    date = if args.key? :date
      Date.iso8601(args[:date])
    else
      Time.current.to_date
    end
    puts "Sending loan summaries for #{date}"
    ActivityNotifier.new(date).send_daily_loan_summaries
  end
end

desc "Send reminders to pending mambers older than 1 month"
task :send_pending_member_reminders, [:date] => :environment do |task, args|
  Time.use_zone("America/Chicago") do
    date = if args.key? :date
      Date.iso8601(args[:date])
    else
      Time.current.to_date
    end
    puts "Sending membership reminders for pending members older than #{date}"
    ActivityNotifier.new(date).remind_pending_members
  end
end

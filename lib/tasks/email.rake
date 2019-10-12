desc "Send daily loan summary emails"
task :send_daily_loan_summaries, [:date] => :environment do |task, args|
  Time.use_zone("America/Chicago") do
    date = Date.iso8601(args[:date])
    puts "Sending loan summaries for #{date}"
    ActivityNotifier.new(date).send_daily_loan_summaries
  end
end

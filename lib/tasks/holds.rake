namespace :holds do
  desc "Check for holds that should be started and send emails to members"
  task start_waiting_holds: :environment do
    Hold.start_waiting_holds_and_notify
  end

  task set_expires_at: :environment do
    Time.use_zone("America/Chicago") do
      Hold.where("started_at IS NOT NULL AND ended_at IS NULL AND started_at > ?", 1.week.ago).find_each do |hold|
        hold.start!(hold.started_at)
      end
    end
  end
end

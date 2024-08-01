namespace :holds do
  desc "Check for holds that should be started and send emails to members"
  task start_waiting_holds: :environment do
    Time.use_zone("America/Chicago") do
      holds = []
      Hold.start_waiting_holds { |hold| holds << hold }

      holds.group_by(&:member).each do |member, member_holds|
        MemberMailer.with(member:, holds: member_holds).holds_available.deliver_now
        MemberTexter.new(member).holds_available(member_holds)
      end
    end
  end

  task set_expires_at: :environment do
    Time.use_zone("America/Chicago") do
      Hold.where("started_at IS NOT NULL AND ended_at IS NULL AND started_at > ?", 1.week.ago).each do |hold|
        hold.start!(hold.started_at)
      end
    end
  end
end

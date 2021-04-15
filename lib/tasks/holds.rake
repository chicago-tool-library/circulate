namespace :holds do
  desc "Check for holds that should be started and send emails to members"
  task start_waiting_holds: :environment do
    Time.use_zone("America/Chicago") do
      Hold.start_waiting_holds do |hold|
        MemberMailer.with(member: hold.member, hold: hold).hold_available.deliver_later
      end
    end
  end
end

require "securerandom"

namespace :members do
  desc "find or create members for existing users"
  task match_users_to_members: :environment do
    User.all.each do |user|
      match = Member.where(email: user.email).first
      if match
        match.user = user
        match.save!
        puts "found match for #{user.email}"
      else
        puts "creating member for #{user.email}"
        Member.create!(user: user, email: user.email, full_name: user.email, phone_number: "7732420923", address1: "1048 W. 37th St.", postal_code: "60609")
      end
    end
  end

  desc "create users for members without them"
  task create_missing_users: :environment do
    Member.open.each do |member|
      if member.user
        puts "#{member.email} has a user"
        next
      end

      password = SecureRandom.hex
      begin
        new_user = User.create!(email: member.email, password: password)
        member.user = new_user
        member.save(validate: false)
      rescue ActiveRecord::RecordInvalid => e
        puts "failed to create a user for #{member.email}: #{e}"
      end
    end
  end
end

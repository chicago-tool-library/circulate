require "open3"

def run_and_print(command)
  puts command
  Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
    while (line = stdout_err.gets)
      puts line
    end

    exit_status = wait_thr.value
    unless exit_status.success?
      abort "command failed: #{cmd}"
    end
  end
end

desc "Load production data and modify for local usage"
task load_production_data: [:pull_production_database, :environment] do
  raise "no way buddy" if Rails.env.production?

  delete_attachments
  scrub_users

  Event.update_all(calendar_id: "appointmentSlots@calendar.google.com")
end

def delete_attachments
  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
end

def scrub_users
  User.update_all(<<~SQL)
    encrypted_password='$2a$11$O4hy2DQEdCZ9lMsDa.ZXHuQfd44FUAAKcdv3ddWEAvCak9Ug4K6Ae',
    email=coalesce('member'||member_id, 'user'||id) || '@example.com',
    current_sign_in_ip = '1.1.1.1',
    last_sign_in_ip = '1.1.1.1',
    reset_password_token = NULL,
    reset_password_sent_at = NULL
  SQL
end

def scrub_data
  Notification.delete_all

  # this could be scoped down to just those that are on members in the future
  ActionText::RichText.delete_all
  Note.delete_all

  Event.update_all(calendar_id: ENV["APPOINTMENT_SLOT_CALENDAR_ID"])

  scrub_users

  Member.update_all(<<~SQL)
    full_name = 'Firstname ' || id || ' Lastname', 
    preferred_name = 'Member ' || id,
    email = 'member' || id || '@example.com',
    phone_number = '7732420923',
    pronouns = '{"she/her", "they/their"}',
    address1 = '1048 W 37th St',
    address2 = 'Suite 102',
    postal_code = '60609'
  SQL

  GiftMembership.update_all(<<-SQL)
    purchaser_email = 'purchaser' || id || '@example.com',
    purchaser_name = 'Purchaser ' || id,
    recipient_name = 'Recipient ' || id,
    code = 'ABCD' || id
  SQL
end

namespace :staging do
  desc "Reset staging with a new scrubbed dataset from production"
  task reset: ["staging:update_database", "staging:update_s3"]

  task scrub_data: :environment do
    scrub_data
  end

  task :update_database do
    raise "no way buddy" if Rails.env.production?

    sh "rails db:create", verbose: true
    sh "rails bin/rails db:environment:set", verbose: true
    sh "rails db:drop", verbose: true
    sh "heroku pg:pull DATABASE circulate_staging --app chicagotoollibrary", verbose: true
    sh "rails staging:scrub_data"
    sh "heroku pg:reset DATABASE_URL --app circulate-staging --confirm circulate-staging", verbose: true
    sh "heroku pg:push circulate_staging DATABASE_URL --app circulate-staging", verbose: true
  end

  task :update_s3 do
    run_and_print "aws s3 sync s3://#{ENV.fetch("BUCKETEER_PRODUCTION_BUCKET_NAME")} ./s3 --profile production"
    run_and_print "aws s3 sync ./s3 s3://#{ENV.fetch("BUCKETEER_STAGING_BUCKET_NAME")} --profile staging"
  end
end

desc "Pulls production database into local develeopment database"
task :pull_production_database do
  puts `rails db:drop`
  puts `heroku pg:pull DATABASE circulate_development --app chicagotoollibrary`
end

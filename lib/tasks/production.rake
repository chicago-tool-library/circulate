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

# This is useful when trying to reproduce a production issue, but it's best to
# avoid doing it live.
desc "Load production data and modify for local usage"
task load_production_data: [:pull_production_database, :environment] do
  raise "no way buddy" if Rails.env.production?
  delete_attachments
  exorcise_production_remnants
end

# Anonymize or delete data for use in development, staging, or wider distribution.
desc "Load production data and modify for export"
task load_production_data_for_export: [:pull_production_database, :environment] do
  raise "no way buddy" if Rails.env.production?
  delete_attachments
  scrub_data
  exorcise_production_remnants
end

desc "Export data for eventual import using pg_restore"
task :create_database_dump do
  path = "exports/#{Date.current}.pgdump"
  `pg_dump --no-acl --no-owner --clean --format=custom circulate_development > #{path}`
end

def delete_attachments
  ActiveStorage::VariantRecord.delete_all
  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
end

def exorcise_production_remnants
  # This prevents being annoyed when you decide you're done working with the data export
  # and want to drop or otherwise mangle your local database.
  ActiveRecord::Base.connection.execute(<<~SQL)
    UPDATE ar_internal_metadata SET value='development' WHERE key='environment';
  SQL

  # This extension is used on Heroku and likes to leak into schema.rb after importing production data.
  ActiveRecord::Base.connection.execute(<<~SQL)
    DROP EXTENSION IF EXISTS pg_stat_statements;
    DROP SCHEMA IF EXISTS heroku_ext;
  SQL
end

def scrub_data
  Note.delete_all

  # Contains emails and phone numbers
  Notification.delete_all

  Appointment.update_all(comment: "")

  GiftMembership.update_all(<<-SQL)
    purchaser_email = 'purchaser' || id || '@example.com',
    purchaser_name = 'Purchaser ' || id,
    recipient_name = 'Recipient ' || id,
    code = 'ABCD' || id
  SQL

  Member.connection.execute(<<~SQL)
    UPDATE members
    SET
      full_name = 'Firstname Lastname',
      preferred_name = coalesce('Member '||members.number, 'User '||users.id),
      email=coalesce('member'||members.number, 'user'||users.id) || '@example.com',
      phone_number = '7732420923',
      pronouns = '{"she/her", "they/their"}',
      address1 = '1048 W 37th St',
      address2 = 'Suite 102',
      postal_code = '60609',
      desires = NULL
    FROM users
    WHERE users.id = members.user_id
  SQL

  # There are some members in the database without associated users that the above query doesn't update.
  Member.where.missing(:user).each { |m| m.destroy }

  User.connection.execute(<<~SQL)
    UPDATE users
    SET
      encrypted_password='$2a$11$O4hy2DQEdCZ9lMsDa.ZXHuQfd44FUAAKcdv3ddWEAvCak9Ug4K6Ae',
      email=coalesce('member'||members.number, 'user'||users.id) || '@example.com',
      current_sign_in_ip = '1.1.1.1',
      last_sign_in_ip = '1.1.1.1',
      reset_password_token = NULL,
      reset_password_sent_at = NULL
    FROM members
    WHERE users.id = members.user_id
  SQL

  Adjustment.where.not(square_transaction_id: nil).update_all(square_transaction_id: "sqtrxnid")
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

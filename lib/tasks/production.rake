desc "Load production data and modify for local usage"
task load_production_data: [:pull_production_database, :environment] do
  raise "no way buddy" if Rails.env.production?

  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
  User.all.each do |user|
    user.update!(
      password: "password",
      email: "user#{user.id}@domain.test",
      current_sign_in_ip: "1.1.1.1",
      last_sign_in_ip: "1.1.1.1"
    )
  end
end

def delete_attachments
  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
end

def scrub_data
  User.in_batches.each_record do |user|
    user.update!(
      password: "password",
      email: "user#{user.id}@domain.test",
      current_sign_in_ip: "1.1.1.1",
      last_sign_in_ip: "1.1.1.1"
    )
  end
  Member.in_batches.each_record do |member|
    id = member.id
    member.update!(
      full_name: "Firstname #{id} Lastname",
      preferred_name: "Member #{id}",
      email: "member#{id}@example.com",
      phone_number: "7732420923",
      pronouns: ["she/her"],
      notes: nil,
      address1: "1048 W 37th St",
      address2: "Suite 102",
      postal_code: 60609
    )
  end
  GiftMembership.in_batches.each_record do |gift_membership|
    id = gift_membership.id
    gift_membership.update!(
      purchaser_email: "purchaser#{id}@domain.test",
      purchaser_name: "Purchaser #{id}",
      recipient_name: "Recipient #{id}",
      code: GiftMembershipCode.new("ABCD#{id}")
    )
  end

  Notification.delete_all
end

desc "Update staging database with latest scrubbed data"
task update_staging_database: [:pull_production_database, :environment] do
  raise "no way buddy" if Rails.env.production?

  scrub_data

  puts `heroku pg:reset DATABASE_URL --app ctl-staging --confirm ctl-staging`
  puts `heroku pg:push circulate_development DATABASE_URL --app ctl-staging`
end

desc "Update analysis database with latest scrubbed data"
task update_analysis_database: [:pull_production_database, :environment] do
  raise "no way buddy" if Rails.env.production?

  scrub_data
  delete_attachments

  puts `heroku pg:reset DATABASE_URL --app chicago-tool-library-data --confirm chicago-tool-library-data`
  puts `heroku pg:push circulate_development DATABASE_URL --app chicago-tool-library-data`
end

desc "Pulls production database into local develeopment database"
task pull_production_database: :environment do
  puts `rails db:drop`
  puts `heroku pg:pull DATABASE circulate_development --app chicagotoollibrary`
end

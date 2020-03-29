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

desc "Update analysis database with latest scrubbed data"
task update_analysis_database: [:load_production_data] do
  Member.in_batches.each_record do |member|
    id = member.id
    member.update!(
      full_name: "Firstname #{id} Lastname",
      preferred_name: "Human #{id}",
      email: "human#{id}@domain.test",
      phone_number: "3124567890",
      pronoun: nil,
      custom_pronoun: nil,
      notes: nil,
      address1: "#{id} streetname st.",
      address2: "apt. #{id}",
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
  puts `heroku pg:backups:capture` # just in case
  puts `heroku pg:reset HEROKU_POSTGRESQL_BLACK`
  puts `heroku pg:push circulate_development HEROKU_POSTGRESQL_BLACK`
  puts `heroku pg:credentials:url HEROKU_POSTGRESQL_BLACK_URL`
end

desc "Pulls production database into local develeopment database"
task :pull_production_database do
  puts `dropdb circulate_development`
  puts `heroku pg:pull DATABASE circulate_development`
end

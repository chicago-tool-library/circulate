desc "Load production data and modify for local usage"
task load_production_data: [:pull_production_database, :environment] do
  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
  User.where(email: "admin@chicagotoollibrary.org").first.update!(password: "password")
end

desc "Pulls production database into local develeopment database"
task :pull_production_database do
  puts `dropdb circulate_development`
  puts `heroku pg:pull DATABASE circulate_development`
end

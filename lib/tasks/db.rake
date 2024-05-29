namespace :db do
  desc "Closes all other connections to the database"
  task close_connections: :environment do
    ActiveRecord::Base.connection.select_all "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where datname='circulate_development' AND state='idle';"
    puts "Connections dropped."
  rescue ActiveRecord::NoDatabaseError
    puts "Skipping; no database found!"
    # fail silently; there's no database to close connections to.
  end
end

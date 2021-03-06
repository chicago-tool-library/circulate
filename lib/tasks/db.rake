namespace :db do
  desc "Closes all other connections to the database"
  task close_connections: :environment do
    ActiveRecord::Base.connection.select_all "select pg_terminate_backend(pg_stat_activity.pid) from pg_stat_activity where datname='circulate_development' AND state='idle';"
  end
end

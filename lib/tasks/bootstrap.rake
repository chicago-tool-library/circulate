desc "Bootstrap a new Heroku application"
task :bootstrap => "db:schema:load" do
  puts "all set!"
end
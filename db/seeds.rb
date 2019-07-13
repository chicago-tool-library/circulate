# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

YAML.load_file("db/tags.yaml").each do |name|
  Tag.create!(name: name)
end

User.create!(email: "admin@chicagotoollibrary.org", password: "password")
BorrowPolicy.create!(name: "Default", fine: Money.new(100), fine_period: 1, duration: 7)

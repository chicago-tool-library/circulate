# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_category(name, kids:nil, parent_id: nil)
  category = Category.create!(name: name, parent_id: parent_id)
  return if kids.nil?

  case kids
  when String
    create_category(kids, parent_id: category.id)
  when Array
    kids.each do |kid|
      create_category(kid, parent_id: category.id)
    end
  when Hash
    create_category(kids.keys.first, kids:kids.values.first, parent_id: category.id)
  else
    raise "kids was not a String, Array, or Hash"
  end
end

YAML.load_file("db/categories.yaml").each do |name, kids|
  create_category(name, kids: kids)
end

User.create!(email: "admin@chicagotoollibrary.org", password: "password")
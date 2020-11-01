# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_category(name, kids: nil, parent_id: nil)
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
    create_category(kids.keys.first, kids: kids.values.first, parent_id: category.id)
  else
    raise "kids was not a String, Array, or Hash"
  end
end

YAML.load_file("db/categories.yaml").each do |name, kids|
  create_category(name, kids: kids)
end

admin_member = Member.create!(
  email: "admin@chicagotoollibrary.org", full_name: "Admin Member", preferred_name: "Admin",
  phone_number: "3124567890", pronouns: ["she/her"], id_kind: 0, address_verified: false, desires: "saws, hammers",
  address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: "60666",
  reminders_via_email: true, reminders_via_text: true, receive_newsletter: true, volunteer_interest: true
)
User.create!(email: admin_member.email, password: "password", member: admin_member, role: "admin")

a_policy = BorrowPolicy.create!(code: "A", name: "Uncounted", fine_period: 1, duration: 7, renewal_limit: 52, uniquely_numbered: false, member_renewable: true)
b_policy = BorrowPolicy.create!(code: "B", name: "Default", fine: Money.new(100), fine_period: 1, duration: 7)
c_policy = BorrowPolicy.create!(code: "C", name: "One Renewal", fine: Money.new(100), fine_period: 1, duration: 7, renewal_limit: 1)

Document.create!(name: "Agreement", code: "agreement", summary: "Member Waiver of Indemnification")
Document.create!(name: "Borrow Policy", code: "borrow_policy", summary: "Covers the rules of borrowing. Shown on the first page of member signup.")
Document.create!(name: "Chicago Tool Library Code of Conduct", code: "code_of_conduct", summary: "Defines acceptable behavior for CTL")

verified_member = Member.create!(
  email: "verifiedmember@example.com", full_name: "Firstname Lastname", preferred_name: "Verified", status: 1,
  phone_number: "3124567890", pronouns: ["she/her"], id_kind: 0, address_verified: true, desires: "saws, hammers",
  address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: "60666",
  reminders_via_email: true, reminders_via_text: true, receive_newsletter: true, volunteer_interest: true
)
User.create!(email: verified_member.email, password: "password", member: verified_member)
verified_member.memberships.create!(started_on: Time.current)

unverified_member = Member.create!(
  email: "newmember@example.com", full_name: "Firstname Lastname", preferred_name: "New",
  phone_number: "3124567890", pronouns: ["she/her"], id_kind: 0, address_verified: false, desires: "saws, hammers",
  address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: "60666",
  reminders_via_email: true, reminders_via_text: true, receive_newsletter: true, volunteer_interest: true
)
User.create!(email: unverified_member.email, password: "password", member: unverified_member)

Item.create!( name: "Flathead Screwdriver", status: Item.statuses[:active], borrow_policy: a_policy )
Item.create!( name: "Hammer", status: Item.statuses[:active], borrow_policy: b_policy )
Item.create!( name: "Cordless Drill", status: Item.statuses[:active], borrow_policy: c_policy )

Item.all.each do |item|
  Loan.create!(
    item: item,
    member: verified_member,
    due_at: 2.days.from_now,
    uniquely_numbered: true
  )
end

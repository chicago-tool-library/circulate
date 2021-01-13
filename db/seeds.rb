admin_member = Member.create!(
  email: "admin@chicagotoollibrary.org", full_name: "Admin Member", preferred_name: "Admin",
  phone_number: "3124567890", pronouns: ["she/her"], id_kind: 0, address_verified: false, desires: "saws, hammers",
  address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: "60666",
  reminders_via_email: true, reminders_via_text: true, receive_newsletter: true, volunteer_interest: true
)
User.create!(email: admin_member.email, password: "password", member: admin_member, role: "admin")

verified_member = Member.create!(
  email: "verifiedmember@example.com", full_name: "Firstname Lastname", preferred_name: "Verified", status: 1,
  phone_number: "3124567890", pronouns: ["she/her"], id_kind: 0, address_verified: true, desires: "saws, hammers",
  address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: "60666",
  reminders_via_email: true, reminders_via_text: true, receive_newsletter: true, volunteer_interest: true
)
User.create!(email: verified_member.email, password: "password", member: verified_member)
verified_member.memberships.create!(started_at: Time.current)

unverified_member = Member.create!(
  email: "newmember@example.com", full_name: "Firstname Lastname", preferred_name: "New",
  phone_number: "3124567890", pronouns: ["she/her"], id_kind: 0, address_verified: false, desires: "saws, hammers",
  address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: "60666",
  reminders_via_email: true, reminders_via_text: true, receive_newsletter: true, volunteer_interest: true
)
User.create!(email: unverified_member.email, password: "password", member: unverified_member)

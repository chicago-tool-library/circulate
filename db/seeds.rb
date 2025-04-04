ActiveSupport.on_load(:action_mailer) do
  Rails.application.reload_routes_unless_loaded
end

ActionMailer::Base.perform_deliveries = false

def seed_library(library, email_suffix = "", postal_code = "60609")
  ActsAsTenant.with_tenant(library) do
    member_attrs = {
      phone_number: "5005550006", pronouns: ["she/her"], id_kind: 0, address_verified: false, desires: "saws, hammers",
      address1: "123 S. Streetname St.", address2: "Apt. 4", city: "Chicago", region: "IL", postal_code: postal_code,
      reminders_via_email: true, reminders_via_text: false, receive_newsletter: true, volunteer_interest: true
    }

    confirmed_email_attrs = {confirmation_sent_at: Time.current, confirmed_at: Time.current}

    admin_user = User.create!(email: "admin#{email_suffix}@example.com", password: "password", role: "admin", **confirmed_email_attrs)
    Member.create!(member_attrs.merge(
      email: admin_user.email, full_name: "Admin Member", preferred_name: "Admin", user: admin_user
    ))

    unconfirmed_email_user = User.create!(email: "member_with_unconfirmed_email#{email_suffix}@example.com", password: "password", unconfirmed_email: "member_with_unconfirmed_email#{email_suffix}@example.com")
    Member.create!(member_attrs.merge(
      email: unconfirmed_email_user.email, full_name: "Unconfirmed Email", preferred_name: "Unconfirmed Email", user: unconfirmed_email_user
    ))

    verified_user = User.create!(email: "verified_member#{email_suffix}@example.com", password: "password", **confirmed_email_attrs)
    verified_member = Member.create!(member_attrs.merge(
      email: verified_user.email, full_name: "Firstname Lastname", preferred_name: "Verified", status: 1, address_verified: true, user: verified_user
    ))
    verified_member.memberships.create!(started_at: Time.current, ended_at: 1.year.since)

    unverified_user = User.create!(email: "new_member#{email_suffix}@example.com", password: "password", **confirmed_email_attrs)
    Member.create!(member_attrs.merge(
      email: unverified_user.email, full_name: "Firstname Lastname", preferred_name: "New", user: unverified_user
    ))

    member_for_18_months_user = User.create!(email: "member_for_18_months#{email_suffix}@example.com", password: "password", **confirmed_email_attrs)
    member_for_18_months = Member.create!(member_attrs.merge(
      email: member_for_18_months_user.email, full_name: "Member for Eighteen Months", preferred_name: "18mo", status: 1, address_verified: true, user: member_for_18_months_user
    ))
    Membership.create!(member: member_for_18_months, started_at: 18.months.ago, ended_at: 6.months.ago)
    Membership.create!(member: member_for_18_months, started_at: 6.months.ago + 1.day, ended_at: 6.months.since - 1.day)

    expired_user = User.create!(email: "expired_member#{email_suffix}@example.com", password: "password", **confirmed_email_attrs)
    expired_member = Member.create!(member_attrs.merge(
      email: expired_user.email, full_name: "Expired Member", preferred_name: "Expired", status: 1, address_verified: true, user: expired_user
    ))
    Membership.create!(member: expired_member, started_at: 18.months.ago, ended_at: 6.months.ago)

    expires_in_one_week_user = User.create!(email: "expires_soon#{email_suffix}@example.com", password: "password", **confirmed_email_attrs)
    expires_in_one_week_member = Member.create!(member_attrs.merge(
      email: expires_in_one_week_user.email, full_name: "Expires Soon Member", preferred_name: "Soon", status: 1, address_verified: true, user: expires_in_one_week_user
    ))
    Membership.create!(member: expires_in_one_week_member, started_at: 351.days.ago, ended_at: 14.days.since)

    # Hardcoding this value (the value of which is "password") means that user sessions aren't invalidated when running
    # bin/setup and you won't have to log in again.
    User.update_all(encrypted_password: "$2a$11$7iZBpCm6HGkC0B4fSbJCCen2IalyVwtDraM249IArh36CSQyqXuOa")

    Time.use_zone "America/Chicago" do
      monday_morning_at_midnight = Time.current.at_beginning_of_week

      52.times do |week| # for each week in the next year
        3.upto(5).each do |day| # on Thursday, Friday, and Saturday
          ten_am = monday_morning_at_midnight + week.weeks + day.days + 10.hours
          noon = ten_am + 2.hours
          two_pm = ten_am + 4.hours

          # Create morning and afternoon appointment slots
          Event.create!(calendar_id: "appointmentSlots@calendar.google.com", calendar_event_id: "morning#{week}#{day}#{email_suffix}", start: ten_am, finish: noon)
          Event.create!(calendar_id: "appointmentSlots@calendar.google.com", calendar_event_id: "afternoon#{week}#{day}#{email_suffix}", start: noon, finish: two_pm)
        end
      end
    end

    LibraryUpdate.create(title: "December updates", body: "<h1>Library Closures!</h1><div>The tool library will be closed for a bit.</div>", published: true)

    1.upto(5).each do |i|
      Organization.create!(name: "Organization #{i}")
    end
  end
end

chicago_tool_library = Library.create!(
  name: "Chicago Tool Library",
  hostname: "chicago.circulate.local",
  city: "Chicago",
  email: "team@chicagotoollibrary.org",
  address: <<~ADDRESS.strip,
    The Chicago Tool Library
    1048 W 37th Street Suite 102
    Chicago, IL 60609
  ADDRESS
  member_postal_code_pattern: "60707|60827|^606"
)
seed_library(chicago_tool_library)

denver_tool_library = Library.create!(
  name: "Denver Tool Library",
  hostname: "denver.circulate.local",
  city: "Denver",
  email: "team@denvertoollibrary.org",
  address: <<~ADDRESS.strip,
    Denver Tool Library
    Denver, CO
  ADDRESS
  member_postal_code_pattern: "^802"
)
seed_library(denver_tool_library, ".denver", "80219")

User.create!(
  email: "super.admin@example.com",
  password: "password",
  library: Library.first,
  role: "super_admin",
  confirmation_sent_at: Time.current,
  confirmed_at: Time.current
)

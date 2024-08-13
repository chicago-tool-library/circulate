require "test_helper"

class MemberTest < ActiveSupport::TestCase
  include Lending

  test "strips no digits from phone number" do
    member = Member.new(phone_number: "(123) 456-7890")
    member.valid?

    assert_equal "1234567890", member.phone_number
  end

  test "finds member by partial email" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("person")
  end

  test "finds member by partial full name" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("B. Wells")
  end

  test "finds member by partial preferred name" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("Ida")
  end

  test "finds member by partial phone number" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("0006")
  end

  test "finds member by formatted phone number" do
    member = FactoryBot.build(:member)
    member.save

    assert_equal [member], Member.matching("(500) 555-0006")
  end

  test "checks postal codes against the library's pattern" do
    library = create(:library, member_postal_code_pattern: "60707|60827|^606")
    ActsAsTenant.with_tenant(library) do
      member = build(:member)

      member.postal_code = "60609"
      assert member.valid?

      member.postal_code = "60707"
      assert member.valid?

      member.postal_code = "60827"
      assert member.valid?

      member.postal_code = "90210"
      refute library.allows_postal_code? "90210"
      refute member.valid?
      assert member.errors.messages.include?(:postal_code)
      error_message = "must be one of: 60707, 60827, 606xx"
      assert member.errors.messages[:postal_code].include?(error_message)
    end
  end

  test "member without a user has a role 'member'" do
    member = Member.new

    assert_equal [:member], member.roles
    assert member.member?
  end

  test "member with a user has a default role of 'member'" do
    user = User.new
    member = Member.new(user: user)

    assert_equal [:member], member.roles
    assert member.member?
  end

  test "a 'staff' member has the role 'staff' and 'member'" do
    user = User.new(role: "staff")
    member = Member.new(user: user)

    assert_equal [:member, :staff], member.roles
    assert member.staff?
  end

  test "an 'admin' member has the role 'admin', 'staff', and 'member'" do
    user = User.new(role: "admin")
    member = Member.new(user: user)

    assert_equal [:member, :staff, :admin], member.roles
    assert member.admin?
  end

  test "can find its upcoming appointment of a hold" do
    member = create(:member)
    hold = create(:hold, member: member)

    assert_nil member.upcoming_appointment_of(hold), "it should return nil if there is no appointment found"

    appointment = create(:appointment, member: member, starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours, holds: [hold])
    assert_equal appointment, member.upcoming_appointment_of(hold)
  end

  test "can find its upcoming appointment of a loan" do
    member = create(:member)
    loan = create(:loan, member: member)

    assert_nil member.upcoming_appointment_of(loan), "it should return nil if there is no appointment found"

    appointment = create(:appointment, member: member, starts_at: 1.day.from_now, ends_at: 1.day.from_now + 2.hours, loans: [loan])
    assert_equal appointment, member.upcoming_appointment_of(loan)
  end

  test "updates user email when member email is updated" do
    member = create(:member, email: "original@example.com")

    assert_equal "original@example.com", member.email
    assert_equal "original@example.com", member.user.email

    assert member.update(email: "revised@different.biz")

    member.user.reload
    assert_equal "revised@different.biz", member.user.email
  end

  test "doesn't allow multiple users with the same email address" do
    create(:member, email: "test@notunique.obv")
    dupe = build(:member, email: "test@notunique.obv")

    refute dupe.valid?
    assert dupe.errors.messages.include?(:email)
  end

  test "downcases member email in the database" do
    member = create(:member, email: "emailWithCapitalLetters@example.com")

    assert_equal "emailwithcapitalletters@example.com", member.email
  end

  test "a member can have an optional bio" do
    member = FactoryBot.build(:member, :with_bio)
    member.save

    assert_equal Member.last.bio, member.bio
  end

  test "a member can have an optional pronunciation" do
    member = FactoryBot.build(:member, :with_pronunciation)
    member.save

    assert_equal Member.last.pronunciation, member.pronunciation
  end

  test "last_membership finds the only membership" do
    member = create(:member)
    membership = create(:membership, member: member)

    assert_equal membership, member.last_membership
  end

  test "last_membership finds the last membership" do
    member = create(:member)
    create(:membership, member: member, created_at: 14.months.ago, started_at: 13.months.ago, ended_at: 1.month.ago)
    newer_membership = create(:membership, member: member, created_at: 1.month.ago, started_at: 1.month.ago, ended_at: 11.months.since)

    assert_equal newer_membership, member.last_membership
  end

  test "last_membership returns nil when there are no memberships" do
    member = create(:member)

    assert_nil member.last_membership
  end

  test "schedules a job for updating Neon membership when enabled" do
    member = create(:member)
    mock = Minitest::Mock.new
    mock.expect :call, true, [Integer]

    NeonMemberJob.stub :perform_later, mock do
      member.stub :can_update_neon_crm?, true do
        member.update(city: "#{member.city} Test")
      end
    end

    assert_mock mock
  end

  test "sends welcome text when phone number is set or updated" do
    original_number = "5551234567"
    member = create(
      :member,
      phone_number: original_number,
      reminders_via_text: true
    )

    # Create of member sends welcome
    assert_equal 1, TwilioHelper::FakeSMS.messages.length
    text = TwilioHelper::FakeSMS.messages.last
    assert_includes text.to, member.phone_number
    assert_includes text.body, "Hello!"

    # Update to phone-number re-sends welcome
    updated_number = "5557654321"
    member.phone_number = updated_number
    member.save!

    assert_equal 2, TwilioHelper::FakeSMS.messages.length
    text = TwilioHelper::FakeSMS.messages.last
    assert_includes text.to, updated_number
    assert_includes text.body, "Hello!"

    # Update to non-phone-number does not send another text
    member.preferred_name = "Ishmael"
    member.save!
    assert_equal 2, TwilioHelper::FakeSMS.messages.length

    # Uncheck of reminders_via_text does not send another text
    member.reminders_via_text = false
    member.save!
    assert_equal 2, TwilioHelper::FakeSMS.messages.length

    # Recheck of reminders_via_text does send another text
    member.reminders_via_text = true
    member.save!
    assert_equal 3, TwilioHelper::FakeSMS.messages.length
    text = TwilioHelper::FakeSMS.messages.last
    assert_includes text.to, member.phone_number
    assert_includes text.body, "Hello!"
  end

  test "welcome text is skipped if feature flag is off" do
    FeatureFlags.stub :sms_reminders_enabled?, false do
      create(:member, reminders_via_text: true)
      assert_equal 0, TwilioHelper::FakeSMS.messages.length
    end
  end

  test "welcome text does not explode if it fails" do
    error = RuntimeError.new("oh no")
    Spy.on(MemberTexter, :new).and_raise(error)
    appsignal_spy = Spy.on(Appsignal, :send_error)

    create(
      :member,
      reminders_via_text: true
    )

    assert appsignal_spy.has_been_called_with?(error)
  end

  test "can destroy member with renewals" do
    loan = create(:overdue_loan)
    renew_loan(loan)
    assert_nothing_raised do
      loan.member.destroy
    end
  end
end

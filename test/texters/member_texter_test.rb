require "test_helper"
require "test_helpers/twilio_helper"

class MemberTexterTest < ActionMailer::TestCase
  setup do
    BaseTexter.client = TwilioHelper::FakeSMS.new
    TwilioHelper::FakeSMS.messages.clear
  end

  teardown do
    BaseTexter.client = nil
  end

  test "sends an overdue notice to the member" do
    member = build(:member)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    text = TwilioHelper::FakeSMS.messages.first
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "4 overdue items"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, TwilioHelper::SEGMENT_LENGTH, "fits in a single SMS segment"
  end

  test "skips overdue notice if the member has not opted into text reminders" do
    member = build(:member, reminders_via_text: false)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of a successful overdue notice" do
    member = create(:member)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.first

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "overdue_notice", notification.action
  end

  test "sends a return reminder to the member" do
    member = build(:member)
    summaries = [:list, :of, :summaries, :due, :tomorrow]

    MemberTexter.new(member).return_reminder(summaries)

    text = TwilioHelper::FakeSMS.messages.first
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "5 items due tomorrow"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, TwilioHelper::SEGMENT_LENGTH, "fits in a single SMS segment"
  end

  test "skips return reminder if the member has not opted into text reminders" do
    member = build(:member, reminders_via_text: false)
    summaries = [:list, :of, :summaries, :due, :tomorrow]

    MemberTexter.new(member).return_reminder(summaries)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of a successful return reminder" do
    member = create(:member)
    summaries = [:list, :of, :summaries, :due, :tomorrow]

    MemberTexter.new(member).return_reminder(summaries)

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.first

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "return_reminder", notification.action
  end

  test "sends a hold available message to the member" do
    member = create(:member)
    hold = create(:hold)

    MemberTexter.new(member).hold_available(hold)

    text = TwilioHelper::FakeSMS.messages.first
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "Your hold for #{hold.item.complete_number} is available"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, 160, "fits in one SMS segment"
  end

  test "skips hold available message if the member has not opted into text reminders" do
    member = build(:member, reminders_via_text: false)
    hold = create(:hold)

    MemberTexter.new(member).hold_available(hold)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of the hold available message" do
    member = create(:member)
    hold = create(:hold)

    MemberTexter.new(member).hold_available(hold)

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.first

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "hold_available", notification.action
  end

  test "sends a welcome message to the member" do
    member = build(:member)

    MemberTexter.new(member).welcome_info

    text = TwilioHelper::FakeSMS.messages.first
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "Hello!"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, TwilioHelper::SEGMENT_LENGTH, "fits in a single SMS segment"
  end

  test "stores a notification record of the welcome message" do
    member = create(:member)

    MemberTexter.new(member).welcome_info

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.first

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "welcome_info", notification.action
  end
end

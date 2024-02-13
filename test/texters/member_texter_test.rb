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
end

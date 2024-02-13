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
  end

  test "skips the notice if the member has not opted into text reminders" do
    member = build(:member, reminders_via_text: false)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of a successful message" do
    member = create(:member)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.first

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
  end

  test "sends a hold available message to the member" do
    member = create(:member)
    hold = create(:hold)

    MemberTexter.new(member).hold_available(hold)

    text = TwilioHelper::FakeSMS.messages.first
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "Your hold for #{hold.item.complete_number} is available"
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
end

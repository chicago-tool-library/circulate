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
end

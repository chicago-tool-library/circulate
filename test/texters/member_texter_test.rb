require "test_helper"

class MemberTexterTest < ActionMailer::TestCase
  test "sends an overdue notice to the member" do
    member = create(:verified_member, reminders_via_text: true)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    text = TwilioHelper::FakeSMS.messages.last
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "4 overdue items"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, TwilioHelper::SEGMENT_LENGTH, "fits in a single SMS segment"
  end

  test "skips overdue notice if the member has not opted into text reminders" do
    member = build(:verified_member, reminders_via_text: false)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of a successful overdue notice" do
    member = create(:verified_member, reminders_via_text: true)
    summaries = [:list, :of, :overdue, :summaries]

    MemberTexter.new(member).overdue_notice(summaries)

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.last

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "overdue_notice", notification.action
  end

  test "sends a return reminder to the member" do
    member = create(:verified_member, reminders_via_text: true)
    summaries = [:list, :of, :summaries, :due, :tomorrow]

    MemberTexter.new(member).return_reminder(summaries)

    text = TwilioHelper::FakeSMS.messages.last
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "5 items due tomorrow"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, TwilioHelper::SEGMENT_LENGTH, "fits in a single SMS segment"
  end

  test "skips return reminder if the member has not opted into text reminders" do
    member = build(:verified_member, reminders_via_text: false)
    summaries = [:list, :of, :summaries, :due, :tomorrow]

    TwilioHelper::FakeSMS.messages.clear

    MemberTexter.new(member).return_reminder(summaries)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of a successful return reminder" do
    member = create(:verified_member, reminders_via_text: true)
    summaries = [:list, :of, :summaries, :due, :tomorrow]

    MemberTexter.new(member).return_reminder(summaries)

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.last

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "return_reminder", notification.action
  end

  test "sends a hold available message to the member" do
    member = create(:verified_member, reminders_via_text: true)
    hold = create(:hold, member: member)

    reasonable_hour = Time.current.change(hour: 9, min: 0)
    travel_to reasonable_hour do
      MemberTexter.new(member).hold_available(hold)
    end

    text = TwilioHelper::FakeSMS.messages.last
    assert_equal text.to, member.canonical_phone_number
    assert_nil text.schedule_type
    assert_nil text.send_at
    assert_equal "accepted", text.status
    assert_includes text.body, "Your hold for #{hold.item.complete_number} is available"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, 160, "fits in one SMS segment"
  end

  test "sends a holds available message to the member (multiple holds)" do
    member = create(:verified_member, reminders_via_text: true)
    holds = create_list(:hold, 3, member:)
    item_numbers = holds.map { |hold| hold.item.complete_number }.join(", ")

    reasonable_hour = Time.current.change(hour: 9, min: 0)
    travel_to reasonable_hour do
      MemberTexter.new(member).holds_available(holds)
    end

    text = TwilioHelper::FakeSMS.messages.last
    assert_equal text.to, member.canonical_phone_number
    assert_nil text.schedule_type
    assert_nil text.send_at
    assert_equal "accepted", text.status
    assert_includes text.body, "Your holds for #{item_numbers} are available"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, 160, "fits in one SMS segment"
  end

  test "sends a holds available message to the member (one hold)" do
    member = create(:verified_member, reminders_via_text: true)
    hold = create(:hold, member: member)

    reasonable_hour = Time.current.change(hour: 9, min: 0)
    travel_to reasonable_hour do
      MemberTexter.new(member).holds_available([hold])
    end

    text = TwilioHelper::FakeSMS.messages.last
    assert_equal text.to, member.canonical_phone_number
    assert_nil text.schedule_type
    assert_nil text.send_at
    assert_equal "accepted", text.status
    assert_includes text.body, "Your hold for #{hold.item.complete_number} is available"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, 160, "fits in one SMS segment"
  end

  test "schedules a hold available message for tomorrow morning if it's after 8pm" do
    member = create(:verified_member, reminders_via_text: true)
    hold = create(:hold, member: member)

    Time.use_zone("America/Chicago") do
      late = Time.current.change(hour: 20, min: 1) # 8:01PM local time
      travel_to late do
        MemberTexter.new(member).hold_available(hold)
      end

      text = TwilioHelper::FakeSMS.messages.last
      tomorrow_morning = late.tomorrow.change(hour: 9, min: 0, sec: 0)
      assert_equal "fixed", text.schedule_type
      assert_equal tomorrow_morning, text.send_at

      notification = Notification.last
      assert_equal "scheduled", notification.status
    end
  end

  test "skips hold available message if the member has not opted into text reminders" do
    member = create(:verified_member, reminders_via_text: false)
    hold = create(:hold)

    TwilioHelper::FakeSMS.messages.clear

    MemberTexter.new(member).hold_available(hold)

    assert_empty TwilioHelper::FakeSMS.messages
  end

  test "stores a notification record of the hold available message" do
    member = create(:verified_member, reminders_via_text: true)
    hold = create(:hold, member: member)

    reasonable_hour = Time.current.change(hour: 9, min: 0)
    travel_to reasonable_hour do
      MemberTexter.new(member).hold_available(hold)
    end

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.last

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "hold_available", notification.action
  end

  test "sends a welcome message to the member" do
    member = build(:verified_member, reminders_via_text: true)

    MemberTexter.new(member).welcome_info

    text = TwilioHelper::FakeSMS.messages.last
    assert_equal text.to, member.canonical_phone_number
    assert_includes text.body, "Hello!"
    refute_match %r{\n\z}, text.body, "does not end in newline"
    assert_operator text.body.length, :<=, TwilioHelper::SEGMENT_LENGTH, "fits in a single SMS segment"
  end

  test "skips welcome message if member has not opted in" do
    member = build(:verified_member, reminders_via_text: false)

    MemberTexter.new(member).welcome_info

    assert_equal 0, TwilioHelper::FakeSMS.messages.length, "no text was sent"
  end

  test "stores a notification record of the welcome message" do
    member = create(:verified_member, reminders_via_text: true)

    MemberTexter.new(member).welcome_info

    notification = Notification.last
    text = TwilioHelper::FakeSMS.messages.last

    assert_equal text.to, notification.address
    assert_equal text.body, notification.subject
    assert_equal member.id, notification.member_id
    assert_equal "accepted", notification.status
    assert_equal "welcome_info", notification.action
  end
end

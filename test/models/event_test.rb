require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "creates new events" do
    gcal_event = GoogleCalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["person@example.com"],
      start: Time.new(2020, 11, 5, 18, 0),
      finish: Time.new(2020, 11, 5, 20, 0),
      status: "confirmed",
      description: "more info"
    )

    assert_difference "Event.count" do
      Event.update_events([gcal_event])
    end

    new_event = Event.where(
      calendar_id: "CAL1",
      calendar_event_id: "ev1"
    ).first

    assert new_event
    assert_equal ["person@example.com"], new_event.attendees
    assert_equal Time.new(2020, 11, 5, 18, 0), new_event.start
    assert_equal Time.new(2020, 11, 5, 20, 0), new_event.finish
    assert_equal "more info", new_event.description
  end

  test "updates events" do
    Event.create(
      calendar_event_id: "ev1",
      calendar_id: "CAL1",
      summary: "summary before",
      description: "description before",
      start: Time.new(2020, 11, 12, 18, 0),
      finish: Time.new(2020, 11, 12, 20, 0),
      attendees: ["fake@example.com"]
    )

    gcal_event = GoogleCalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["someone-else@example.com"],
      start: Time.new(2020, 11, 5, 18, 0),
      finish: Time.new(2020, 11, 5, 20, 0),
      status: "confirmed",
      description: "more info"
    )

    assert_no_difference "Event.count" do
      Event.update_events([gcal_event])
    end

    updated_event = Event.where(
      calendar_id: "CAL1",
      calendar_event_id: "ev1"
    ).first

    assert updated_event
    assert_equal ["someone-else@example.com"], updated_event.attendees
    assert_equal Time.new(2020, 11, 5, 18, 0), updated_event.start
    assert_equal Time.new(2020, 11, 5, 20, 0), updated_event.finish
    assert_equal "more info", updated_event.description
  end

  test "deletes events" do
    Event.create(
      calendar_event_id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["person@example.com"],
      start: Time.new(2020, 11, 5, 18, 0),
      finish: Time.new(2020, 11, 5, 20, 0),
      description: "more info"
    )

    gcal_event = GoogleCalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["someone-else@example.com"],
      start: Time.new(2020, 11, 5, 18, 0),
      finish: Time.new(2020, 11, 5, 20, 0),
      status: "cancelled",
      description: "more info"
    )

    assert_difference "Event.count", -1 do
      Event.update_events([gcal_event])
    end

    updated_event = Event.where(
      calendar_id: "CAL1",
      calendar_event_id: "ev1"
    ).first

    refute updated_event
  end

  test "handles cancelled events that have already been deleted" do
    Event.create(
      calendar_event_id: "ev2",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["person@example.com"],
      start: Time.new(2020, 11, 5, 18, 0),
      finish: Time.new(2020, 11, 5, 20, 0),
      description: "more info"
    )

    gcal_event = GoogleCalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["someone-else@example.com"],
      start: Time.new(2020, 11, 5, 18, 0),
      finish: Time.new(2020, 11, 5, 20, 0),
      status: "cancelled",
      description: "more info"
    )

    assert_difference "Event.count", 0 do
      Event.update_events([gcal_event])
    end
  end
end

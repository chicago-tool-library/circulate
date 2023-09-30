# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "creates new events" do
    gcal_event = Google::CalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: [Attendee.new(email: "person@example.com", name: "A Person", status: "accepted")],
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
    assert_equal [Attendee.new(email: "person@example.com", name: "A Person", status: "accepted")], new_event.attendees
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
      attendees: [Attendee.new(email: "person@example.com", name: "A Person", status: "accepted")]
    )

    gcal_event = Google::CalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: [Attendee.new(email: "someone-else@example.com", name: "Someone Else", status: "needsAction")],
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
    assert_equal [Attendee.new(email: "someone-else@example.com", name: "Someone Else", status: "needsAction")], updated_event.attendees
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

    gcal_event = Google::CalendarEvent.new(
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

    assert_not updated_event
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

    gcal_event = Google::CalendarEvent.new(
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

  test "times on the hour" do
    Time.use_zone("America/Chicago") do
      event = create(:event,
        start: Time.zone.local(2020, 11, 5, 18, 0),
        finish: Time.zone.local(2020, 11, 5, 20, 0))
      assert_equal "6pm - 8pm", event.times
    end
  end

  test "times with minutes" do
    Time.use_zone("America/Chicago") do
      event = create(:event,
        start: Time.zone.local(2020, 11, 5, 18, 15),
        finish: Time.zone.local(2020, 11, 5, 20, 30))
      assert_equal "6:15pm - 8:30pm", event.times
    end
  end

  test "upcoming_slots includes slots that end more than 15 minutes in the future" do
    create(:event, start: 106.minutes.ago, finish: 14.minutes.since, calendar_id: Event.appointment_slot_calendar_id)
    ends_in_sixteen_minutes = create(:event, start: 104.minutes.ago, finish: 16.minutes.since, calendar_id: Event.appointment_slot_calendar_id)

    assert_equal [ends_in_sixteen_minutes.id], Event.appointment_slots.pluck(:id)
  end

  test "returns a basic summary" do
    event = Event.new(summary: "Something simple")

    assert_equal "Something simple", event.title
  end

  test "removes parenthesized text" do
    event = Event.new(summary: "Something simple (and complex) ")

    assert_equal "Something simple", event.title
  end
end

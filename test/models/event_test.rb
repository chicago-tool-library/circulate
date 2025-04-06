require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "creates new events" do
    gcal_event = Google::CalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: [Attendee.new(email: "person@example.com", name: "A Person", status: "accepted")],
      start: Time.zone.local(2020, 11, 5, 18, 0),
      finish: Time.zone.local(2020, 11, 5, 20, 0),
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
    assert_equal Time.zone.local(2020, 11, 5, 18, 0), new_event.start
    assert_equal Time.zone.local(2020, 11, 5, 20, 0), new_event.finish
    assert_equal "more info", new_event.description
  end

  test "updates events" do
    Event.create(
      calendar_event_id: "ev1",
      calendar_id: "CAL1",
      summary: "summary before",
      description: "description before",
      start: Time.zone.local(2020, 11, 12, 18, 0),
      finish: Time.zone.local(2020, 11, 12, 20, 0),
      attendees: [Attendee.new(email: "person@example.com", name: "A Person", status: "accepted")]
    )

    gcal_event = Google::CalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: [Attendee.new(email: "someone-else@example.com", name: "Someone Else", status: "needsAction")],
      start: Time.zone.local(2020, 11, 5, 18, 0),
      finish: Time.zone.local(2020, 11, 5, 20, 0),
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
    assert_equal Time.zone.local(2020, 11, 5, 18, 0), updated_event.start
    assert_equal Time.zone.local(2020, 11, 5, 20, 0), updated_event.finish
    assert_equal "more info", updated_event.description
  end

  test "deletes events" do
    Event.create(
      calendar_event_id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["person@example.com"],
      start: Time.zone.local(2020, 11, 5, 18, 0),
      finish: Time.zone.local(2020, 11, 5, 20, 0),
      description: "more info"
    )

    gcal_event = Google::CalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["someone-else@example.com"],
      start: Time.zone.local(2020, 11, 5, 18, 0),
      finish: Time.zone.local(2020, 11, 5, 20, 0),
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
      start: Time.zone.local(2020, 11, 5, 18, 0),
      finish: Time.zone.local(2020, 11, 5, 20, 0),
      description: "more info"
    )

    gcal_event = Google::CalendarEvent.new(
      id: "ev1",
      calendar_id: "CAL1",
      summary: "a quick event",
      attendees: ["someone-else@example.com"],
      start: Time.zone.local(2020, 11, 5, 18, 0),
      finish: Time.zone.local(2020, 11, 5, 20, 0),
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

  test "next_open_day returns first date after passed time with an event on the appointment_slot_calendar_id" do
    past_event = create(:appointment_slot_event, start: 1.day.ago)
    next_event = create(:appointment_slot_event, start: 2.days.from_now)
    future_event = create(:appointment_slot_event, start: 4.days.from_now)

    assert_equal next_event.start.to_date, Event.next_open_day, "finds first open day from now"
    assert_equal next_event.start.to_date, Event.next_open_day(2.days.from_now), "finds same-day open date"
    assert_equal past_event.start.to_date, Event.next_open_day(2.days.ago), "finds next open day from past"
    assert_equal future_event.start.to_date, Event.next_open_day(3.days.from_now), "finds next open day in future"
    error = assert_raises(RuntimeError, "raises error when no open days found") {
      Event.next_open_day(7.days.from_now)
    }
    assert_match "No open day found on or after #{7.days.from_now.to_date}", error.message
  end

  test "next_open_day returns the next day as the next open day" do
    monday = Time.utc(2020, 1, 20)
    tuesday = Time.utc(2020, 1, 21)
    wednesday = Time.utc(2020, 1, 22)
    thursday = Time.utc(2020, 1, 23)
    friday = Time.utc(2020, 1, 24)
    saturday = Time.utc(2020, 1, 25)
    sunday = Time.utc(2020, 1, 26)

    create(:appointment_slot_event, start: thursday)
    create(:appointment_slot_event, start: sunday)

    assert_equal thursday, Event.next_open_day(monday)
    assert_equal thursday, Event.next_open_day(tuesday)
    assert_equal thursday, Event.next_open_day(wednesday)
    assert_equal thursday, Event.next_open_day(thursday)

    assert_equal sunday, Event.next_open_day(friday)
    assert_equal sunday, Event.next_open_day(saturday)
    assert_equal sunday, Event.next_open_day(sunday)
  end
end

# frozen_string_literal: true

require "test_helper"

class ShiftsHelperTest < ActionView::TestCase
  test "event_attendees returns preferred member names in a list" do
    member1 = create(:member, preferred_name: "member one")
    member2 = create(:member, preferred_name: "member two")

    attendee1 = Attendee.new(email: member1.email, status: "accepted")
    attendee2 = Attendee.new(email: member2.email, status: "accepted")

    assert_equal "member one, member two", event_attendees([attendee1, attendee2])
  end

  test "event_attendees ignored attendees who haven't accepted" do
    attendee1 = Attendee.new(email: "attendee1@example.com", status: "accepted")
    attendee2 = Attendee.new(email: "attendee2@example.com", status: "declined")
    attendee3 = Attendee.new(email: "attendee3@example.com", status: "tentative")
    attendee4 = Attendee.new(email: "attendee4@example.com", status: "needsAction")

    assert_equal "attendee1", event_attendees([attendee1, attendee2, attendee3, attendee4])
  end
end

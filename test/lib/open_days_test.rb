require "test_helper"

class OpenDaysTest < ActiveSupport::TestCase
  TIME_SLOTS = [
    OpenStruct.new(day: "Thursday", from: 18, to: 20),
    OpenStruct.new(day: "Saturday", from: 11, to: 13)
  ].freeze

  def setup
    Time.zone = "America/Chicago"
    Chronic.time_class = Time.zone
  end

  test "returns possible time slots" do
    travel_to DateTime.new(2020, 9, 21)
    slots = OpenDays.next_slots(weeks: 2, time_slots: TIME_SLOTS)

    assert_equal slots.count, 8
    assert_equal slots[0].to_s, Time.zone.local(2020, 9, 24, 18, 0, 0).to_s
    assert_equal slots[1].to_s, Time.zone.local(2020, 9, 24, 19, 0, 0).to_s
    assert_equal slots[2].to_s, Time.zone.local(2020, 9, 26, 11, 0, 0).to_s
    assert_equal slots[3].to_s, Time.zone.local(2020, 9, 26, 12, 0, 0).to_s

    assert_equal slots[4].to_s, Time.zone.local(2020, 10, 1, 18, 0, 0).to_s
    assert_equal slots[5].to_s, Time.zone.local(2020, 10, 1, 19, 0, 0).to_s
    assert_equal slots[6].to_s, Time.zone.local(2020, 10, 3, 11, 0, 0).to_s
    assert_equal slots[7].to_s, Time.zone.local(2020, 10, 3, 12, 0, 0).to_s
    travel_back
  end

  # This handles an edge case:
  # We're asking for time slots for Thursday and Saturday,
  # if today is Friday, it's going to parse first the date for the
  # next Thursday (which is only next week) and then the date for
  # the next Saturday which is earlier than the next Wednesday.
  #
  test "returns dates in ascending order" do
    travel_to DateTime.new(2020, 9, 25, 14, 0, 0)
    slots = OpenDays.next_slots(weeks: 2, time_slots: TIME_SLOTS)

    assert_equal slots.count, 8
    assert_equal slots[0].to_s, Time.zone.local(2020, 9, 26, 11, 0, 0).to_s
    assert_equal slots[1].to_s, Time.zone.local(2020, 9, 26, 12, 0, 0).to_s

    assert_equal slots[2].to_s, Time.zone.local(2020, 10, 1, 18, 0, 0).to_s
    assert_equal slots[3].to_s, Time.zone.local(2020, 10, 1, 19, 0, 0).to_s
    assert_equal slots[4].to_s, Time.zone.local(2020, 10, 3, 11, 0, 0).to_s
    assert_equal slots[5].to_s, Time.zone.local(2020, 10, 3, 12, 0, 0).to_s

    assert_equal slots[6].to_s, Time.zone.local(2020, 10, 8, 18, 0, 0).to_s
    assert_equal slots[7].to_s, Time.zone.local(2020, 10, 8, 19, 0, 0).to_s
    travel_back
  end

  test "next_slots_for_select: returns formatted time slots" do
    travel_to DateTime.new(2020, 9, 24, 14, 0, 0)
    assert_equal OpenDays.next_slots_for_select(weeks: 2, time_slots: TIME_SLOTS), {
      "Sat Sep 26" => [
        ["11 am to 12 pm", Time.parse("Sat, 26 Sep 2020 11:00:00 -0500")..Time.parse("Sat, 26 Sep 2020 12:00:00 -0500")],
        ["12 pm to 1 pm", Time.parse("Sat, 26 Sep 2020 12:00:00 -0500")..Time.parse("Sat, 26 Sep 2020 13:00:00 -0500")]
      ],
      "Thu Oct 1" => [
        ["6 pm to 7 pm", Time.parse("Thu, 01 Oct 2020 18:00:00 -0500")..Time.parse("Thu, 01 Oct 2020 19:00:00 -0500")],
        ["7 pm to 8 pm", Time.parse("Thu, 01 Oct 2020 19:00:00 -0500")..Time.parse("Thu, 01 Oct 2020 20:00:00 -0500")]
      ],
      "Sat Oct 3" => [
        ["11 am to 12 pm", Time.parse("Sat, 03 Oct 2020 11:00:00 -0500")..Time.parse("Sat, 03 Oct 2020 12:00:00 -0500")],
        ["12 pm to 1 pm", Time.parse("Sat, 03 Oct 2020 12:00:00 -0500")..Time.parse("Sat, 03 Oct 2020 13:00:00 -0500")]
      ],
      "Thu Oct 8" => [
        ["6 pm to 7 pm", Time.parse("Thu, 08 Oct 2020 18:00:00 -0500")..Time.parse("Thu, 08 Oct 2020 19:00:00 -0500")],
        ["7 pm to 8 pm", Time.parse("Thu, 08 Oct 2020 19:00:00 -0500")..Time.parse("Thu, 08 Oct 2020 20:00:00 -0500")]
      ]
    }
    travel_back
  end
end

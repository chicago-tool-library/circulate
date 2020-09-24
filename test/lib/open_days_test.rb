require "test_helper"

class ActivityNotifierTest < ActiveSupport::TestCase
  TIME_SLOTS = [
    OpenStruct.new(day: "Thursday", from: 18, to: 20),
    OpenStruct.new(day: "Saturday", from: 11, to: 13),
  ].freeze

  test "returns possible time slots" do
    Timecop.freeze(DateTime.new(2020, 9, 21)) do
      slots = OpenDays.next_slots(weeks: 2, time_slots: TIME_SLOTS)

      assert_equal slots.count, 8
      assert_equal slots[0].to_s, Time.local(2020, 9, 24, 18, 0, 0).to_s
      assert_equal slots[1].to_s, Time.local(2020, 9, 24, 19, 0, 0).to_s
      assert_equal slots[2].to_s, Time.local(2020, 9, 26, 11, 0, 0).to_s
      assert_equal slots[3].to_s, Time.local(2020, 9, 26, 12, 0, 0).to_s

      assert_equal slots[4].to_s, Time.local(2020, 10, 1, 18, 0, 0).to_s
      assert_equal slots[5].to_s, Time.local(2020, 10, 1, 19, 0, 0).to_s
      assert_equal slots[6].to_s, Time.local(2020, 10, 3, 11, 0, 0).to_s
      assert_equal slots[7].to_s, Time.local(2020, 10, 3, 12, 0, 0).to_s
    end
  end

  test "next_slots_for_select: returns formatted time slots" do
    assert_equal OpenDays.next_slots_for_select(weeks: 2), {}
  end
end

require "test_helper"

class ReservationsHelperTest < ActionView::TestCase
  test "format_reservation_event shows the date, start time, and finish time" do
    base_time = Date.new(2024, 8, 24).at_noon
    event = build(:event, start: base_time, finish: base_time + 1.hour)
    assert_equal "24 Aug 12:00pm - 1:00pm", format_reservation_event(event)
  end
end

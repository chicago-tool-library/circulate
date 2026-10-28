require "test_helper"

class ReservationsHelperTest < ActionView::TestCase
  test "format_reservation_event shows the date, start time, and finish time" do
    base_time = Date.new(2024, 8, 24).at_noon
    event = build(:event, start: base_time, finish: base_time + 1.hour)
    assert_equal "24 Aug 12:00pm - 1:00pm", format_reservation_event(event)
  end

  test "format_usage_fee describes an item pool's fees" do
    assert_nil format_usage_fee(build(:item_pool))
    assert_equal "$10.00", format_usage_fee(build(:item_pool, usage_fee: 10))
    assert_equal "$2.00 every day", format_usage_fee(build(:item_pool, periodic_fee: 2))
    assert_equal "$10.00 + $2.00 every 7 days",
      format_usage_fee(build(:item_pool, usage_fee: 10, periodic_fee: 2, periodic_fee_period: 7))
  end
end

require "test_helper"

class TicketUpdateTest < ActiveSupport::TestCase
  test "has a valid factory/trait" do
    ticket_update = build(:ticket_update)
    ticket_update.valid?
    assert_equal({}, ticket_update.errors.messages)
  end
end

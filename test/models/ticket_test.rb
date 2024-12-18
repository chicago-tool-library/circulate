require "test_helper"

class TicketTest < ActiveSupport::TestCase
  test "has tags" do
    ticket = create(:ticket)

    ticket.tag_list.add("awesome", "not awesome")
    assert ticket.save

    ticket.reload

    assert_equal ["awesome", "not awesome"], ticket.tag_list

    ticket.tag_list.remove("not awesome")

    assert ticket.save

    ticket.reload
    assert_equal ["awesome"], ticket.tag_list
  end
end

require "test_helper"

class HoldTest < ActiveSupport::TestCase
  test "#upcoming_appointment should call its member.upcoming_appointment_of with itself" do
    member_double = Minitest::Mock.new
    hold = create(:hold)
    hold.stub :member, member_double do
      member_double.expect(:upcoming_appointment_of, nil, [hold])
      hold.upcoming_appointment
    end
  end

  test "is ready for pickup if item is uncounted" do
    item = create(:uncounted_item)

    hold = create(:hold, item: item)
    assert hold.ready_for_pickup?

    second_hold = create(:hold, item: item)
    assert second_hold.ready_for_pickup?
  end
end

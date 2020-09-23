require 'test_helper'

class AppointmentTest < ActiveSupport::TestCase
  test "creates an appointment" do
    appointment = FactoryBot.create(:appointment)

    assert_equal "My Comment", appointment.comment
  end
end

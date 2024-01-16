require "application_system_test_case"

module Admin
  class AppointmentHoldsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @appointment = FactoryBot.build(:appointment)
      @user = FactoryBot.create(:user)
      @member = FactoryBot.create(:member, user: @user)
      @hold = FactoryBot.create(:hold, member: @member)
      @appointment.holds << @hold
      @appointment.member = @member
      @appointment.starts_at = "2020-10-05 7:00AM"
      @appointment.ends_at = "2020-10-05 8:00AM"
      @appointment.save

      @user = create(:admin_user)
      sign_in @user
    end

    test "remove item with cancel_hold true" do
      # Test that when `cancel_hold` is true, the hold is deleted from the appointment
      # *and* the member's holds. This test emulates the behavior of the "Cancel Hold"
      # button on the librarian view of an appointment.
      assert_difference("@appointment.holds.count", -1) do
        assert_difference("@member.holds.count", -1) do
          delete admin_appointment_hold_path(@appointment, @hold), params: {cancel_hold: true}
        end
      end
    end

    test "remove item with cancel_hold false" do
      # Test that when `cancel_hold` is false, the hold is deleted from the appointment
      # but the member still has the hold. This test emulates the behavior of the
      # "Remove Item" button on the librarian view of an appointment.
      assert_difference("@appointment.holds.count", -1) do
        assert_no_difference("@member.holds.count") do
          delete admin_appointment_hold_path(@appointment, @hold), params: {cancel_hold: false}
        end
      end
    end
  end
end

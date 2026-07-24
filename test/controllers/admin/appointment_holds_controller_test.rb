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

    test "removing an item the member already took off the appointment" do
      # Members can edit their own appointments, so the librarian's page can be
      # stale by the time they click. Removing an item that is already gone
      # should land them back on the appointment rather than erroring, and it
      # must not cancel the member's hold instead (#2212).
      @appointment.appointment_holds.destroy_all

      assert_no_difference("@member.holds.count") do
        delete admin_appointment_hold_path(@appointment, @hold), params: {cancel_hold: true}
      end

      assert_redirected_to admin_appointment_path(@appointment)
      assert_equal "That item is no longer on this appointment. The member may have updated it.", flash[:warning]
      assert Hold.exists?(@hold.id), "the member's hold should survive"
    end

    test "cannot cancel a hold belonging to a different appointment" do
      # params[:id] is only trustworthy once we've confirmed the hold is on
      # this appointment, otherwise "Cancel Hold" can destroy someone else's.
      other_appointment = FactoryBot.create(:appointment_with_holds)
      other_hold = other_appointment.holds.first

      assert_no_difference("Hold.count") do
        assert_no_difference("AppointmentHold.count") do
          delete admin_appointment_hold_path(@appointment, other_hold), params: {cancel_hold: true}
        end
      end

      assert_redirected_to admin_appointment_path(@appointment)
      assert Hold.exists?(other_hold.id), "the other appointment's hold should survive"
    end
  end
end

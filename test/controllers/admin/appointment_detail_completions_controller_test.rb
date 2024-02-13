require "application_system_test_case"

module Admin
  class AppointmentDetailCompletionsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @member = create(:member)
      @loan = create(:loan, member: @member)
      @appointment = build(:appointment, member: @member)
      @appointment.loans << @loan
      @appointment.save!

      @user = create(:admin_user)
      sign_in @user
    end

    test "completes an appointment" do
      post admin_appointment_detail_completion_path(@appointment), as: :turbo_stream

      assert_redirected_to admin_appointments_path
      assert @appointment.reload.completed_at
    end

    test "un-completes an appointment" do
      @appointment.update!(completed_at: Time.current)

      delete admin_appointment_detail_completion_path(@appointment), as: :turbo_stream
      assert_response :success

      assert_nil @appointment.reload.completed_at
    end
  end
end

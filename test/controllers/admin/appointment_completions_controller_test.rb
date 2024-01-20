require "application_system_test_case"

module Admin
  class AppointmentCompletionsControllerTest < ActionDispatch::IntegrationTest
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
      post admin_appointment_completion_path(@appointment), as: :turbo_stream
      assert_response :success

      assert @appointment.reload.completed_at
    end

    test "completes an empty appointment" do
      @appointment.appointment_loans.delete_all

      post admin_appointment_completion_path(@appointment), as: :turbo_stream
      assert_response :success

      assert @appointment.reload.completed_at
    end

    test "un-completes an appointment" do
      @appointment.update!(completed_at: Time.current)

      delete admin_appointment_completion_path(@appointment), as: :turbo_stream
      assert_response :success

      assert_nil @appointment.reload.completed_at
    end
  end
end

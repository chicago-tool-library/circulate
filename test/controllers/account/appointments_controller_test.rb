require "test_helper"

module Account
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @user = FactoryBot.create(:user)
      @member = FactoryBot.create(:member, user: @user)
      sign_in @user
    end

    private def create_appointment
      @hold = FactoryBot.create(:started_hold, member: @member)
      @appointment = FactoryBot.build(:appointment)
      @appointment.holds << @hold
      @appointment.member = @member
      @appointment.starts_at = "2020-10-05 7:00AM"
      @appointment.ends_at = "2020-10-05 8:00AM"
      @appointment.save
    end

    test "creates a new appointment to pickup items on hold" do
      @hold = FactoryBot.create(:started_hold, member: @member)
      @event = FactoryBot.create(:appointment_slot_event)

      post account_appointments_path, params: {appointment: {
        hold_ids: [@hold.id],
        comment: "Excited to start on my project!",
        time_range_string: "#{@event.start}..#{@event.finish}"
      }}

      @appointment = @member.appointments.last
      assert_enqueued_email(MemberMailer, :appointment_confirmation, params: {member: @member, appointment: @appointment})

      assert_redirected_to account_appointments_path
      assert_equal 1, @member.appointments.count
    end

    test "adds additional items to an existing appointment via creation form" do
      create_appointment
      @hold = FactoryBot.create(:started_hold, member: @member)

      post account_appointments_path, params: {appointment: {
        hold_ids: [@hold.id],
        comment: "Excited to start on my project!",
        time_range_string: "#{@appointment.starts_at}..#{@appointment.ends_at}"
      }}

      @appointment = @member.appointments.last
      assert_enqueued_email(MemberMailer, :appointment_updated, params: {member: @member, appointment: @appointment})

      assert_redirected_to account_appointments_path
      assert_equal 1, @member.appointments.count
    end

    test "should cancel appointment without affecting holds" do
      create_appointment
      delete account_appointment_path(@appointment)
      assert_equal 1, @member.holds.count, "Member holds should not be deleted when an appointment is cancelled"
      assert_redirected_to account_appointments_path
    end

    test "should get edit appointment" do
      create_appointment
      get edit_account_appointment_path(@appointment)
      assert_response :success
    end

    test "should update appointment" do
      create_appointment
      assert_equal 1, @appointment.holds.count

      @hold2 = FactoryBot.create(:hold, member: @member)
      put account_appointment_path(@appointment), params: {appointment: {hold_ids: [@hold.id, @hold2.id], time_range_string: @appointment.time_range_string, comment: @appointment.comment}}
      @appointment.reload

      assert_equal 2, @appointment.holds.count
      assert_redirected_to account_appointments_path
    end

    test "should not update appointment with invalid params" do
      create_appointment
      put account_appointment_path(@appointment), params: {appointment: {hold_ids: [], time_range_string: @appointment.time_range_string, comment: @appointment.comment}}

      assert_template :edit
      assert_select "ul.error", /Please select an item to pick-up or return for your appointment/

      @appointment.reload
      assert_equal 1, @appointment.holds.count
    end

    test "should not update appointment scheduled after any holds expire" do
      create_appointment
      @expired_hold = create(:hold, member: @member)
      @expired_hold.start!(@appointment.starts_at - Hold::HOLD_LENGTH - 1.days)
      put account_appointment_path(@appointment), params: {appointment: {hold_ids: [@hold.id, @expired_hold.id], time_range_string: @appointment.time_range_string, comment: @appointment.comment}}

      assert_template :edit
      assert_select "ul.error", /on or before hold expires on/
    end
  end
end

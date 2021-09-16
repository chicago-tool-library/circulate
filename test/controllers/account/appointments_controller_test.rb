require "test_helper"

module Account
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @appointment = FactoryBot.build(:appointment)
      @user = FactoryBot.create(:user)
      @member = FactoryBot.create(:member, user: @user)
      @hold = FactoryBot.create(:started_hold, member: @member)
      @appointment.holds << @hold
      @appointment.member = @member
      @appointment.starts_at = "2020-10-05 7:00AM"
      @appointment.ends_at = "2020-10-05 8:00AM"
      @appointment.save

      sign_in @user
    end

    test "should cancel appointment without affecting holds" do
      delete account_appointment_path(@appointment)
      assert_equal 1, @member.holds.count, "Member holds should not be deleted when an appointment is cancelled"
      assert_redirected_to account_appointments_path
    end

    test "should get edit appointment" do
      get edit_account_appointment_path(@appointment)
      assert_response :success
    end

    test "should update appointment" do
      assert_equal 1, @appointment.holds.count

      @hold2 = FactoryBot.create(:hold, member: @member)
      put account_appointment_path(@appointment), params: {appointment: {hold_ids: [@hold.id, @hold2.id], time_range_string: @appointment.time_range_string, comment: @appointment.comment}}
      @appointment.reload

      assert_equal 2, @appointment.holds.count
      assert_redirected_to account_appointments_path
    end

    test "should not update appointment with invalid params" do
      put account_appointment_path(@appointment), params: {appointment: {hold_ids: [], time_range_string: @appointment.time_range_string, comment: @appointment.comment}}

      assert_template :edit
      assert_select "ul.error", /Please select an item to pick-up or return for your appointment/

      @appointment.reload
      assert_equal 1, @appointment.holds.count
    end

    test "should not update appointment scheduled after any holds expire" do
      @expired_hold = FactoryBot.create(:hold, member: @member, started_at: @appointment.starts_at - Hold::HOLD_LENGTH - 1.days)
      put account_appointment_path(@appointment), params: {appointment: {hold_ids: [@hold.id, @expired_hold.id], time_range_string: @appointment.time_range_string, comment: @appointment.comment}}

      assert_template :edit
      assert_select "ul.error", /on or before hold expires on/
    end
  end
end

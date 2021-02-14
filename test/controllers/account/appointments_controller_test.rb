require "test_helper"

module Account
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
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

      sign_in @user
    end

    test "should cancel appointment without affecting holds" do
      delete account_appointment_path(@appointment)
      assert_nil assigns(:appointment)
      assert_equal 1, @member.holds.count, "Member holds should not be deleted when an appointment is cancelled"
      assert_redirected_to account_appointments_path
    end
  end
end

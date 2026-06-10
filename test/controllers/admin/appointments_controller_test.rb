require "application_system_test_case"

module Admin
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @appointment = FactoryBot.build(:appointment)
      @user = FactoryBot.create(:user)
      @member = FactoryBot.create(:member, user: @user)
      @hold = FactoryBot.create(:hold, member: @member)
      @appointment.holds << @hold
      @loan = create(:loan, member: @member)
      @appointment.loans << @loan
      @appointment.member = @member
      @appointment.starts_at = "2020-10-05 7:00AM"
      @appointment.ends_at = "2020-10-05 8:00AM"
      @appointment.save

      @user = create(:admin_user)
      sign_in @user
    end

    test "index page includes links to item and member" do
      day = @appointment.starts_at.strftime("%F")
      get admin_appointments_path(day: day)

      assert_select "a[href=?]", admin_item_path(@hold.item)
      assert_select "a[href=?]", admin_member_path(@appointment.member)
    end

    test "allows admins to modify appointment time range" do
      starts_at = Time.current
      ends_at = starts_at + 2.hours

      put admin_appointment_path(@appointment), params: {appointment: {time_range_string: "#{starts_at}..#{ends_at}"}}
      assert_redirected_to admin_appointments_url

      @appointment.reload
      assert_equal @appointment.starts_at.to_i, starts_at.to_i
      assert_equal @appointment.ends_at.to_i, ends_at.to_i
    end

    test "renders show page with items to pickup and drop off" do
      assert_nothing_raised do
        get admin_appointment_path(@appointment)
      end
    end

    test "labels a hold that timed out as expired, not checked-out" do
      appointment = build(:appointment, member: @member)
      appointment.holds << create(:hold, :expired, member: @member)
      appointment.save!

      get admin_appointment_path(appointment)

      assert_select "em", text: "Hold expired without pickup"
      assert_select "em", text: "Item checked-out", count: 0
    end

    test "labels a hold that was actually picked up as checked-out" do
      appointment = build(:appointment, member: @member)
      loan = create(:loan, member: @member)
      appointment.holds << create(:hold, :ended, member: @member, loan: loan)
      appointment.save!

      get admin_appointment_path(appointment)

      assert_select "em", text: "Item checked-out"
    end
  end
end

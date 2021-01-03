require "application_system_test_case"

module Admin
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    setup do
      @appointment = FactoryBot.build(:appointment)
      @user = FactoryBot.create(:user)
      @member = FactoryBot.create(:member, user: @user)
      @hold = FactoryBot.create(:hold, creator: @member.user)
      @appointment.holds << @hold
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
  end
end

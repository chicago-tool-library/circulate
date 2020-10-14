require "application_system_test_case"

class AppointmentsTest < ApplicationSystemTestCase
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
    create(:admin_user)
    sign_in_as_admin
  end

  test "index page includes links to item and member" do
    day = @appointment.starts_at.strftime("%F")
    visit "admin/appointments?day=#{day}"
    assert page.html.include? "<a href=\"/items/#{@hold.item.id}"
    assert page.html.include? "<a href=\"/member_profile.#{@appointment.member.id}"
  end

  test "displays correct text when there are no appointments" do
    day = @appointment.starts_at.next_day.strftime("%F")
    visit "admin/appointments?day=#{day}"
    assert_text "No matching appointments for this day!"
  end
end

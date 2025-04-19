require "application_system_test_case"

module Admin
  class AppointmentDetailsTest < ApplicationSystemTestCase
    setup do
      starts_at = Time.current.beginning_of_day + 8.hours

      @member = create(:verified_member_with_membership)
      @hold = create(:hold, member: @member)
      @item = @hold.item
      @appointment = create(:appointment, member: @member, holds: [@hold], starts_at: starts_at + 2.hours, ends_at: starts_at + 4.hours)

      sign_in_as_admin
    end

    test "an admin can mark a pending appointment as pulled" do
      visit admin_appointment_path(@appointment)

      click_on "Pull Items"

      assert_text "Complete"
      assert_text "Mark As Not Pulled"

      @appointment.reload

      assert @appointment.pulled_at?
      refute @appointment.completed_at?
    end

    test "an admin can mark a pulled appointment as pending" do
      @appointment.update!(pulled_at: Time.current)

      visit admin_appointment_path(@appointment)

      click_on "Mark As Not Pulled"

      assert_text "Pull Items"

      @appointment.reload

      refute @appointment.pulled_at?
      refute @appointment.completed_at?
    end

    test "an admin can mark a pulled appointment as complete" do
      @appointment.update!(pulled_at: Time.current)

      visit admin_appointment_path(@appointment)

      click_on "Complete"

      assert_text "Restore"

      @appointment.reload

      assert @appointment.pulled_at?
      assert @appointment.completed_at?
    end

    test "an admin can mark a complete appointment as pulled" do
      @appointment.update!(pulled_at: Time.current, completed_at: Time.current)

      visit admin_appointment_path(@appointment)

      click_on "Restore"

      assert_text "Mark As Not Pulled"
      assert_text "Complete"

      @appointment.reload

      assert @appointment.pulled_at?
      refute @appointment.completed_at?
    end

    test "an admin can check out an item that lacks accessories" do
      @item.update!(accessories: [])
      visit admin_appointment_path(@appointment)
      assert_text @item.name
      click_on "Check-out"
      assert_text "1 Item checked-out."
    end

    test "an admin can see the accessories for an item that's to be checked out" do
      @item.update!(accessories: ["foo", "bar", rand(100).to_s])
      visit admin_appointment_path(@appointment)

      assert_css "button[disabled][id='checkout-#{@hold.id}']"

      @item.accessories.each do |accessory|
        find("label", text: accessory).click # check checkbox
      end

      refute_css "button[disabled][id='checkout-#{@hold.id}']"

      click_on "Check-out"
      assert_text "1 Item checked-out."
    end

    test "an admin can see the accessories for an item that's to be returned" do
      @hold.destroy!
      @item.update!(accessories: ["foo", "bar", rand(100).to_s])
      loan = create(:loan, :checked_out, item: @item)
      @appointment.update!(loans: [loan])

      visit admin_appointment_path(@appointment)

      assert_css "button[disabled][id='checkin-#{loan.id}']"

      @item.accessories.each do |accessory|
        find("label", text: accessory).click # check checkbox
      end

      refute_css "button[disabled][id='checkin-#{loan.id}']"

      click_on "Check-in"
      assert_text "1 Item checked-in."
    end
  end
end

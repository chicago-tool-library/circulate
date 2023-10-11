require "application_system_test_case"

class RemoveHoldsTest < ApplicationSystemTestCase
  setup do
    @member = create(:verified_member_with_membership)
    login_as @member.user
  end

  test "removes hold if it doesn't have an appointment" do
    @held_item = create(:item)
    @hold = create(:hold, item: @held_item, member: @member)

    visit account_holds_path
    accept_confirm { click_link "Remove Hold" }

    assert_text "You have no items on hold"
  end

  test "removes hold from associated appointment if appointment has more than one item" do
    @held_item = create(:item)
    @borrowed_item = create(:item)

    @hold = create(:hold, item: @held_item, member: @member)
    @loan = create(:loan, item: @borrowed_item, member: @member)

    create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 27.hours.since.beginning_of_hour, finish: 28.hours.since.beginning_of_hour)
    @appointment = create(:appointment, member: @member, starts_at: Time.now + 1.day, ends_at: Time.now + 1.day + 2.hours, holds: [@hold], loans: [@loan])

    visit account_holds_path
    accept_confirm { click_link "Remove Hold" }
    click_on "Appointments"

    appointment_card = find("li.appointment")
    within(appointment_card) do
      assert_no_text @held_item.name
      assert_text @borrowed_item.name
    end
  end

  test "removes hold and cancels associated appointment if it's the only item" do
    held_item = create(:item)
    hold = create(:hold, item: held_item, member: @member)
    create(:appointment, member: @member, starts_at: Time.now + 1.day, ends_at: Time.now + 1.day + 2.hours, holds: [hold])

    visit account_holds_path
    accept_confirm { click_link "Remove Hold" }
    click_on "Appointments"

    assert_text "You have no scheduled appointments"
  end
end

require "application_system_test_case"

module Account
  class QuestionsTest < ApplicationSystemTestCase
    include ReservationsHelper

    setup do
      ActionMailer::Base.deliveries.clear

      @member = create(:verified_member_with_membership)
      @admin_user = create(:user, role: "admin", library: @member.library)
      @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)

      login_as @member.user
    end

    def select_first_available_pickup_event
      first_optgroup = find("#reservation_pickup_event_id optgroup", match: :first)
      first_optgroup.find("option", match: :first).select_option
      first_optgroup.text
    end

    def select_last_available_dropoff_event
      all_optgroups = all("#reservation_dropoff_event_id optgroup")
      last_optgroup = all_optgroups.last
      last_optgroup.all("option").last.select_option
      last_optgroup.text
    end

    def create_events
      base_time = 2.days.from_now.at_noon
      [
        create(:event, calendar_id: Event.appointment_slot_calendar_id, start: base_time, finish: base_time + 1.hour),
        create(:event, calendar_id: Event.appointment_slot_calendar_id, start: base_time + 2.days + 2.hours, finish: base_time + 2.days + 3.hours)
      ]
    end

    test "viewing a reservation's questions and answers" do
      reservation = create(:reservation)
      create(:answer) # ignored
      answers = create_list(:answer, 2, reservation:)

      visit account_reservation_url(reservation)

      answers.each do |answer|
        assert_text answer.stem.content
        assert_text answer.value
      end
    end

    test "creating a reservation with questions and answers" do
      create_events
      text_stem = create(:stem, :text)
      integer_stem = create(:stem, :integer)
      create(:stem, :archived) # ignored

      visit new_account_reservation_path
      fill_in "Name", with: @attributes[:name]
      select_first_available_pickup_event
      select_last_available_dropoff_event
      fill_in text_stem.content, with: "text answer"
      fill_in integer_stem.content, with: "150"

      assert_equal 0, Answer.count
      assert_difference("Answer.count", 2) do
        click_on "Continue to Add Items"
        assert_text "Reservation was successfully created"
      end

      assert_equal 1, text_stem.answers.count
      assert_equal 1, integer_stem.answers.count
      assert_equal "text answer", text_stem.answers.first.value
      assert_equal 150, integer_stem.answers.first.value
    end

    test "creating a reservation with questions and answers with errors" do
      create_events
      text_stem = create(:stem, :text)

      visit new_account_reservation_path
      fill_in "Name", with: @attributes[:name]
      select_first_available_pickup_event
      select_last_available_dropoff_event
      fill_in text_stem.content, with: ""

      assert_equal 0, Answer.count
      assert_difference("Answer.count", 0) do
        click_on "Continue to Add Items"
        assert_text "Please correct the errors below"
      end

      assert_equal 0, text_stem.answers.count
      assert_text "can't be blank"
    end
  end
end

require "application_system_test_case"

module Account
  class ReservationsTest < ApplicationSystemTestCase
    include ReservationsHelper

    setup do
      ActionMailer::Base.deliveries.clear

      @member = create(:verified_member_with_membership)
      @admin_user = create(:user, role: "admin", library: @member.library)
      @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)

      login_as @member.user
    end

    def formatted_date_only(datetime)
      datetime.to_fs(:long).sub(/\d\d:\d\d/, "")
    end

    def date_input_format(datetime)
      datetime.strftime("%Y-%m-%d")
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

    test "visiting the index" do
      Time.use_zone("America/Chicago") do
        reservations = [
          create(:reservation, :requested, started_at: 3.days.ago, ended_at: 3.days.from_now, member: @member),
          create(:reservation, :approved, started_at: 2.days.ago, ended_at: 2.days.from_now, member: @member),
          create(:reservation, :rejected, started_at: 4.days.ago, ended_at: 4.days.from_now, member: @member)
        ]

        visit account_reservations_url

        reservations.each do |reservation|
          assert_text reservation.name
          assert_text reservation.status
          assert_text formatted_date_only(reservation.started_at)
          assert_text formatted_date_only(reservation.ended_at)
        end
      end
    end

    test "viewing a reservation" do
      Time.use_zone("America/Chicago") do
        reservation = create(:reservation, started_at: 3.days.ago, ended_at: 3.days.from_now)

        visit account_reservation_url(reservation)

        assert_text reservation.name
        assert_text reservation.status
        assert_text formatted_date_only(reservation.started_at)
        assert_text formatted_date_only(reservation.ended_at)
      end
    end

    test "creating a reservation successfully" do
      first_event, last_event = create_events

      visit new_account_reservation_path

      fill_in "Name", with: @attributes[:name]
      select_first_available_pickup_event
      select_last_available_dropoff_event

      assert_difference("Reservation.count", 1) do
        click_on "Continue to Add Items"
        assert_text @attributes[:name]
      end

      reservation = Reservation.last!

      assert_equal @attributes[:name], reservation.name
      assert_equal @member.id, reservation.member_id
      assert_equal first_event, reservation.pickup_event
      assert_equal last_event, reservation.dropoff_event
    end

    test "creating a reservation with errors" do
      visit new_account_reservation_path
      fill_in "Name", with: ""

      assert_difference("Reservation.count", 0) do
        click_on "Continue to Add Items"
        assert_text "can't be blank"
      end
    end

    test "creating a reservation, adding items, and submitting it" do
      create_events
      hammer_pool = create(:item_pool, name: "Hammer")
      create(:reservable_item, item_pool: hammer_pool)

      visit new_account_reservation_path

      fill_in "Name", with: @attributes[:name]
      select_first_available_pickup_event
      select_last_available_dropoff_event

      click_on "Continue to Add Items"
      assert_text @attributes[:name]

      # add Hammer to reservation
      click_on "Hammer"
      click_on "Add"

      # item has been added
      assert_text "Hammer was added to your reservation"
      assert_text "You have reserved 1 of this item in your current reservation."

      reservation = Reservation.last!

      # TODO: replace this with assertions about the UI
      assert_equal 1, reservation.reservation_holds.count
      assert_equal hammer_pool, reservation.reservation_holds[0].item_pool
      assert_equal 1, reservation.reservation_holds[0].quantity

      click_on "Review and Submit"

      # on reservation page
      click_on "Submit Reservation"
      assert_text "We will review your reservation shortly."

      perform_enqueued_jobs do
        click_on "Submit for Review"
        assert_text "The reservation was submitted."
      end

      assert_emails 2

      assert_delivered_email(to: @member.email, second_to_last: true) do |html, text|
        assert_includes html, "Reservation submitted"
      end

      assert_delivered_email(to: @admin_user.email) do |html, text|
        assert_includes html, "Reservation ready for review"
      end
    end
  end
end

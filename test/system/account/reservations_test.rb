require "application_system_test_case"

module Account
  class ReservationsTest < ApplicationSystemTestCase
    setup do
      ActionMailer::Base.deliveries.clear

      @member = create(:verified_member_with_membership)
      @admin_user = create(:user, role: "admin", library: @member.library)
      @organization = create(:organization)
      @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)

      login_as @member.user
    end

    def formatted_date_only(datetime)
      datetime.to_fs(:long).sub(/\d\d:\d\d/, "")
    end

    def date_input_format(datetime)
      datetime.strftime("%Y-%m-%d")
    end

    test "visiting the index" do
      Time.use_zone("America/Chicago") do
        reservations = [
          create(:reservation, status: "requested", started_at: 3.days.ago, ended_at: 3.days.from_now, organization: @organization),
          create(:reservation, status: "approved", started_at: 2.days.ago, ended_at: 2.days.from_now, organization: @organization),
          create(:reservation, status: "rejected", started_at: 4.days.ago, ended_at: 4.days.from_now, organization: @organization)
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
      visit new_account_reservation_path

      fill_in "Name", with: @attributes[:name]
      find("#start-date-field").set(date_input_format(@attributes[:started_at]))
      find("#end-date-field").set(date_input_format(@attributes[:ended_at]))

      assert_difference("Reservation.count", 1) do
        click_on "Create Reservation"
        assert_text @attributes[:name]
      end

      reservation = Reservation.last!

      assert_equal @attributes[:name], reservation.name
      assert_equal @attributes[:started_at].to_date, reservation.started_at.to_date
      assert_equal (@attributes[:ended_at] + 1.day).to_date, reservation.ended_at.to_date
      assert_equal @member.user, reservation.submitted_by
    end

    test "creating a reservation with errors" do
      visit new_account_reservation_path
      fill_in "Name", with: ""

      assert_difference("Reservation.count", 0) do
        click_on "Create Reservation"
        assert_text "can't be blank"
      end
    end

    test "creating a reservation, adding items, and submitting it " do
      hammer_pool = create(:item_pool, name: "Hammer")
      create(:reservable_item, item_pool: hammer_pool)

      visit new_account_reservation_path

      fill_in "Name", with: @attributes[:name]
      find("#start-date-field").set(date_input_format(@attributes[:started_at]))
      find("#end-date-field").set(date_input_format(@attributes[:ended_at]))

      click_on "Create Reservation"
      assert_text @attributes[:name]

      # add Hammer to reservation
      click_on "Add Items"
      assert_text "Hammer"
      click_on "Add"

      # back on reservation page
      assert_text @attributes[:name]
      assert_text "Hammer"

      reservation = Reservation.last!

      # TODO: replace this with assertions about the UI
      assert_equal 1, reservation.reservation_holds.count
      assert_equal hammer_pool, reservation.reservation_holds[0].item_pool
      assert_equal 1, reservation.reservation_holds[0].quantity

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

require "application_system_test_case"

class AdminReservationsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)
  end

  def formatted_date_only(datetime)
    datetime.to_formatted_s(:long).sub(/\d\d:\d\d/, "")
  end

  def date_input_format(datetime)
    datetime.strftime("%m/%d/%Y")
  end

  test "visiting the index" do
    reservations = [
      create(:reservation, status: "requested", started_at: 3.days.ago, ended_at: 3.days.from_now),
      create(:reservation, status: "approved", started_at: 2.days.ago, ended_at: 2.days.from_now),
      create(:reservation, status: "rejected", started_at: 4.days.ago, ended_at: 4.days.from_now)
    ]

    visit admin_reservations_url

    reservations.each do |reservation|
      assert_text reservation.name
      assert_text reservation.status
      assert_text formatted_date_only(reservation.started_at)
      assert_text formatted_date_only(reservation.ended_at)
    end
  end

  test "viewing a reservation" do
    reservation = create(:reservation, started_at: 3.days.ago, ended_at: 3.days.from_now)

    visit admin_reservation_url(reservation)

    assert_text reservation.name
    assert_text reservation.status
    assert_text formatted_date_only(reservation.started_at)
    assert_text formatted_date_only(reservation.ended_at)
  end

  test "creating a reservation successfully" do
    visit new_admin_reservation_path

    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))

    assert_difference("Reservation.count", 1) do
      click_on "Create Reservation"
      assert_text "Reservation was successfully created"
    end

    reservation = Reservation.last!

    assert_equal @attributes[:name], reservation.name
    assert_equal @attributes[:started_at].to_date, reservation.started_at.to_date
    assert_equal (@attributes[:ended_at] + 1.day).to_date, reservation.ended_at.to_date
  end

  test "creating a reservation with errors" do
    visit new_admin_reservation_path
    fill_in "Name", with: ""

    assert_difference("Reservation.count", 0) do
      click_on "Create Reservation"
      assert_text "can't be blank"
    end
  end

  test "updating a reservation successfully" do
    reservation = create(:reservation)
    visit admin_reservation_path(reservation)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))

    assert_difference("Reservation.count", 0) do
      click_on "Update Reservation"
      assert_text "Reservation was successfully updated"
    end

    reservation.reload

    assert_equal admin_reservation_path(reservation), current_path
    assert_equal @attributes[:name], reservation.name
    assert_equal @attributes[:started_at].to_date, reservation.started_at.to_date
    assert_equal (@attributes[:ended_at] + 1.day).to_date, reservation.ended_at.to_date
  end

  test "updating a reservation with errors" do
    reservation = create(:reservation)
    visit admin_reservation_path(reservation)
    click_on "Edit"

    fill_in "Name", with: ""

    assert_difference("Reservation.count", 0) do
      click_on "Update Reservation"
      assert_text "can't be blank"
    end

    reservation.reload

    refute_equal @attributes[:name], reservation.name
  end

  test "destroying a reservation" do
    reservation = create(:reservation)
    visit edit_admin_reservation_path(reservation)

    assert_difference("Reservation.count", -1) do
      find("summary", text: "destroy this reservation?").click
      accept_confirm do
        click_on("destroy reservation")
      end
      assert_text "Reservation was successfully destroyed."
    end
  end
end

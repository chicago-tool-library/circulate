require "application_system_test_case"

class AdminReservationsTest < ApplicationSystemTestCase
  include ReservationsHelper

  setup do
    sign_in_as_admin
    @organization = create(:organization)
    @attributes = attributes_for(:reservation, started_at: 3.days.from_now.at_noon, ended_at: 10.days.from_now.at_noon).slice(:name, :started_at, :ended_at)
  end

  def formatted_date_only(datetime)
    datetime.to_fs(:long).sub(/\d\d:\d\d/, "")
  end

  def date_input_format(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  def select_first_available_pickup_date
    first_optgroup = find("#reservation_pickup_event_id optgroup", match: :first)
    first_optgroup.find("option", match: :first).select_option
    first_optgroup.text
  end

  def select_last_available_dropoff_date
    first_optgroup = find("#reservation_dropoff_event_id optgroup", match: :first)
    first_optgroup.all("option").last.select_option
    first_optgroup.text
  end

  def create_events
    base_time = 2.days.from_now.at_noon
    [
      create(:event, calendar_id: Event.appointment_slot_calendar_id, start: base_time, finish: base_time + 1.hour),
      create(:event, calendar_id: Event.appointment_slot_calendar_id, start: base_time + 2.hours, finish: base_time + 3.hours)
    ]
  end

  test "visiting the index" do
    Time.use_zone("America/Chicago") do
      reservations = [
        create(:reservation, status: "requested", started_at: 3.days.ago, ended_at: 3.days.from_now, organization: @organization),
        create(:reservation, status: "approved", started_at: 2.days.ago, ended_at: 2.days.from_now, organization: @organization),
        create(:reservation, status: "rejected", started_at: 4.days.ago, ended_at: 4.days.from_now, organization: @organization)
      ]

      visit admin_reservations_url

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
      pickup_event, dropoff_event = create_events
      reservation = create(:reservation, started_at: 3.days.ago, ended_at: 3.days.from_now, pickup_event:, dropoff_event:)

      visit admin_reservation_url(reservation)

      assert_text reservation.name
      assert_text reservation.status
      assert_text formatted_date_only(reservation.started_at)
      assert_text formatted_date_only(reservation.ended_at)
      assert_text format_reservation_event(pickup_event)
      assert_text format_reservation_event(dropoff_event)
    end
  end

  test "viewing a reservation's questions and answers" do
    reservation = create(:reservation)
    create(:answer) # ignored
    answers = create_list(:answer, 2, reservation:)

    visit admin_reservation_url(reservation)
    # TODO: This is a somewhat ambiguous selector that I'm dropping in to fix
    # tests in a sweep. Consider rearranging the view to make it easier to
    # select between the tab and the global nav.
    within(".tab") do
      click_on "Questions"
    end

    answers.each do |answer|
      assert_text answer.stem.content
      assert_text answer.value
    end
  end

  test "viewing a reservation's review notes after review" do
    reservation = create(:reservation, :approved)

    visit admin_reservation_url(reservation)
    click_on "Review Notes"

    assert_text reservation.notes
  end

  test "viewing a reservation's review notes before review" do
    reservation = create(:reservation, notes: "")
    visit admin_reservation_url(reservation)

    refute_text "Review Notes"
  end

  test "creating a reservation successfully" do
    first_event, last_event = create_events

    visit new_admin_reservation_path

    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    select(@organization.name, from: "Organization")
    select_first_available_pickup_date
    select_last_available_dropoff_date

    assert_difference("Reservation.count", 1) do
      click_on "Create Reservation"
      assert_text "Reservation was successfully created"
    end

    reservation = Reservation.last!

    assert_equal @attributes[:name], reservation.name
    assert_equal @attributes[:started_at].to_date, reservation.started_at.to_date
    assert_equal (@attributes[:ended_at] + 1.day).to_date, reservation.ended_at.to_date
    assert_equal @user, reservation.submitted_by
    assert_equal first_event, reservation.pickup_event
    assert_equal last_event, reservation.dropoff_event
  end

  test "creating a reservation with errors" do
    visit new_admin_reservation_path
    fill_in "Name", with: ""

    assert_difference("Reservation.count", 0) do
      click_on "Create Reservation"
      assert_text "can't be blank"
    end
  end

  test "creating a reservation with questions and answers" do
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)
    create(:stem, :archived) # ignored

    visit new_admin_reservation_path
    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    select(@organization.name, from: "Organization")
    fill_in text_stem.content, with: "text answer"
    fill_in integer_stem.content, with: "150"

    assert_equal 0, Answer.count
    assert_difference("Answer.count", 2) do
      click_on "Create Reservation"
      assert_text "Reservation was successfully created"
    end

    assert_equal 1, text_stem.answers.count
    assert_equal 1, integer_stem.answers.count
    assert_equal "text answer", text_stem.answers.first.value
    assert_equal 150, integer_stem.answers.first.value
  end

  test "updating a reservation successfully" do
    reservation = create(:reservation)
    first_event, last_event = create_events

    visit admin_reservation_path(reservation)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    select_first_available_pickup_date
    select_last_available_dropoff_date

    assert_difference("Reservation.count", 0) do
      click_on "Update Reservation"
      assert_text "Reservation was successfully updated"
    end

    reservation.reload

    assert_equal admin_reservation_path(reservation), current_path
    assert_equal @attributes[:name], reservation.name
    assert_equal @attributes[:started_at].to_date, reservation.started_at.to_date
    assert_equal (@attributes[:ended_at] + 1.day).to_date, reservation.ended_at.to_date
    assert_equal first_event, reservation.pickup_event
    assert_equal last_event, reservation.dropoff_event
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

  test "updating a reservation with questions and answers" do
    reservation = create(:reservation)
    text_stem = create(:stem, :text)
    integer_stem = create(:stem, :integer)
    create(:stem, :archived) # ignored
    text_answer = create(:answer, reservation:, stem: text_stem)
    integer_answer = create(:answer, reservation:, stem: integer_stem, value: 3)

    visit admin_reservation_path(reservation)
    click_on "Edit"

    fill_in "Name", with: @attributes[:name]
    find("#start-date-field").set(date_input_format(@attributes[:started_at]))
    find("#end-date-field").set(date_input_format(@attributes[:ended_at]))
    fill_in text_stem.content, with: "text answer"
    fill_in integer_stem.content, with: "150"

    assert_difference("Answer.count", 0) do
      click_on "Update Reservation"
      assert_text "Reservation was successfully updated"
    end

    text_answer.reload
    integer_answer.reload

    assert_equal "text answer", text_answer.value
    assert_equal 150, integer_answer.value
  end

  test "the dropdown for pickup/dropoff events includes old events if already associated" do
    old_pickup_event = create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 3.days.ago, finish: 3.days.ago + 1.hour)
    old_dropoff_event = create(:event, calendar_id: Event.appointment_slot_calendar_id, start: 2.days.ago, finish: 2.days.ago + 1.hour)
    reservation = create(:reservation, pickup_event: old_pickup_event, dropoff_event: old_dropoff_event)

    visit admin_reservation_path(reservation)
    click_on "Edit"

    assert_selector "option[value='#{old_pickup_event.id}']"
    assert_selector "option[value='#{old_dropoff_event.id}']"
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

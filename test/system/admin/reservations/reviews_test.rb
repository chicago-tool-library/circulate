require "application_system_test_case"

class AdminReservationsReviewsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "a reservation can be approved" do
    reservation = create(:reservation, :requested)
    visit admin_reservation_path(reservation)
    click_on "Review"

    review_notes = "These are my notes for reservation #{reservation.id}"
    fill_in "Notes", with: review_notes

    click_on "Approve"

    assert_text "Reservation was successfully updated"

    reservation.reload

    assert_equal "approved", reservation.status
    assert_equal review_notes, reservation.notes
    assert_equal @user, reservation.reviewer

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    assert mail, "must send approval email"
    assert_includes mail.subject, "was approved"
  end

  test "a reservation can be rejected" do
    reservation = create(:reservation, :requested)
    visit admin_reservation_path(reservation)
    click_on "Review"

    review_notes = "These are my notes for reservation #{reservation.id}"
    fill_in "Notes", with: review_notes

    click_on "Reject"

    assert_text "Reservation was successfully updated"

    reservation.reload

    assert_equal "rejected", reservation.status
    assert_equal review_notes, reservation.notes
    assert_equal @user, reservation.reviewer

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    assert mail, "must send rejection email"
    assert_includes mail.subject, "was rejected"
  end

  test "a reservation that is not 'requested' cannot be approved or rejected" do
    reservation = create(:reservation, :approved)
    visit edit_admin_reservation_review_path(reservation)

    assert_text "Can't review a reservation with status approved"
  end
end

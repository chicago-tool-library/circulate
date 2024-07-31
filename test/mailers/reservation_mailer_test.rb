require "application_system_test_case"

class ReservationMailerTest < ApplicationSystemTestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "#reservation_requested includes HTML and text parts when a reservation is submitted" do
    reservation = create(:reservation)

    ReservationMailer.with(reservation:).reservation_requested.deliver_now

    expected_subject = "Reservation submitted for #{reservation.started_at.to_fs(:short_date)}"

    assert_delivered_email(to: reservation.submitted_by.email) do |html, text, _, subject|
      assert_equal expected_subject, subject
      assert_includes html, expected_subject, "mail should include subject in html part"
      assert_includes text, expected_subject, "mail should include subject in text part"
    end
  end

  test "#reviewed includes html and text parts containing the notes when approved" do
    reservation = create(:reservation, :approved)

    ReservationMailer.with(reservation:).reviewed.deliver_now

    message = "Your reservation for #{reservation.started_at.to_fs(:short_date)} was approved"

    assert_delivered_email(to: reservation.submitted_by.email) do |html, text, _, subject|
      assert_equal message, subject

      assert_includes html, message, "mail should include approval message in html part"
      assert_includes html, reservation.notes, "mail should include approval notes in html part"

      assert_includes text, message, "mail should include approval message in text part"
      assert_includes text, reservation.notes, "mail should include approval notes in text part"
    end
  end

  test "#reviewed includes html and text parts containing the notes when rejected" do
    reservation = create(:reservation, :rejected)

    ReservationMailer.with(reservation:).reviewed.deliver_now

    message = "Your reservation for #{reservation.started_at.to_fs(:short_date)} was rejected"

    assert_delivered_email(to: reservation.submitted_by.email) do |html, text, _, subject|
      assert_equal message, subject

      assert_includes html, message, "mail should include rejection message in html part"
      assert_includes html, reservation.notes, "mail should include rejection notes in html part"

      assert_includes text, message, "mail should include rejection message in text part"
      assert_includes text, reservation.notes, "mail should include rejection notes in text part"
    end
  end
end

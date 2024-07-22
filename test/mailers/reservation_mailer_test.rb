require "test_helper"

class ReservationMailerTest < ActionMailer::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "#reservation_requested includes HTML and text parts when a reservation is submitted" do
    reservation = create(:reservation)

    ReservationMailer.with(reservation:).reservation_requested.deliver_now

    mail = ActionMailer::Base.deliveries.last

    subject = "Reservation submitted for #{reservation.started_at.to_fs(:short_date)}"

    assert mail.multipart?, "mail should be multipart"
    assert_equal subject, mail.subject
    assert_equal [reservation.submitted_by.email], mail.to
    assert_includes mail.html_part.body.to_s, subject, "mail should include subject in html part"
    assert_includes mail.text_part.body.to_s, subject, "mail should include subject in text part"
  end
end

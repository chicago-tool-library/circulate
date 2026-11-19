require "test_helper"

class HoldReturnedToLineJobTest < ActiveJob::TestCase
  test "emails the member, mentioning the cancelled appointment" do
    hold = create(:hold)
    starts_at = Time.zone.parse("2026-11-19 12:00")

    HoldReturnedToLineJob.perform_now(hold.id, starts_at, :cancelled)

    mail = ActionMailer::Base.deliveries.last
    assert_equal [hold.member.email], mail.to
    assert_match "isn't ready after all", mail.subject
    assert_match "still first in line", mail.text_part.body.to_s
    assert_match "so we've cancelled it", mail.text_part.body.to_s
  end
end

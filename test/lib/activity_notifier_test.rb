require "test_helper"

class ActivityNotifierTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "send emails to folks who have checked items out in the last 24 hours" do
    loan = create(:loan)
    loan2 = create(:loan, member: loan.member)

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      notifier.send_daily_loan_summaries
    end
    
    refute ActionMailer::Base.deliveries.empty?

    mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == [loan.member.email]}
    refute mail.nil?

    assert_equal "Today's account summary", mail.subject
    assert_includes mail.encoded, loan.item.complete_number
    assert_includes mail.encoded, loan2.item.complete_number
  end

  test "doesn't send emails with old activity" do

    Time.use_zone("America/Chicago") do
      end_of_previous_day = Time.current.beginning_of_day - 1.minute

      travel_to end_of_previous_day do
        loan = create(:loan)
        loan.return!
      end

      notifier = ActivityNotifier.new
      notifier.send_daily_loan_summaries
    end
    
    assert ActionMailer::Base.deliveries.empty?
  end
end

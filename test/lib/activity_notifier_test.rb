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
      assert_difference "Notification.count" do
        notifier.send_daily_loan_summaries
      end
    end

    refute ActionMailer::Base.deliveries.empty?

    mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == [loan.member.email] }
    refute mail.nil?

    assert_equal "Today's loan summary", mail.subject
    assert_includes mail.encoded, loan.item.complete_number
    assert_includes mail.encoded, loan2.item.complete_number
    refute_includes mail.encoded, "return all overdue items as soon as possible"
  end

  test "doesn't send emails with old activity" do
    Time.use_zone("America/Chicago") do
      end_of_previous_day = Time.current.beginning_of_day - 1.minute

      travel_to end_of_previous_day do
        loan = create(:loan)
        loan.return!
      end

      notifier = ActivityNotifier.new
      assert_no_difference "Notification.count" do
        notifier.send_daily_loan_summaries
      end
    end

    assert ActionMailer::Base.deliveries.empty?
  end

  test "sends a single email to folks with both overdue and active loans" do
    loan = create(:loan, due_at: 1.day.ago, created_at: 8.days.ago)
    loan2 = create(:loan, member: loan.member, due_at: 7.days.since)

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      notifier.send_daily_loan_summaries
    end

    refute ActionMailer::Base.deliveries.empty?

    mails = ActionMailer::Base.deliveries.select { |delivery| delivery.to == [loan.member.email] }
    assert_equal 1, mails.size
  end

  test "sends emails to folks with overdue items" do
    loan = Time.use_zone("America/Chicago") {
      create(:loan, due_at: Time.current.end_of_day, created_at: 1.week.ago)
    }

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      assert_difference "Notification.count" do
        notifier.send_daily_loan_summaries
      end
    end

    refute ActionMailer::Base.deliveries.empty?

    assert mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == [loan.member.email] }

    assert_equal "You have overdue items!", mail.subject
    assert_includes mail.encoded, loan.item.complete_number
    assert_includes mail.encoded, "return all overdue items as soon as possible"
  end

  test "only sends emails to folks with items that were due whole weeks ago" do
    days = 60
    item = create(:uncounted_item)

    loans = Time.use_zone("America/Chicago") {
      days.times.map do |i|
        create(:nonexclusive_loan, item: item, due_at: Time.current.end_of_day - i.days, created_at: 1.week.ago)
      end
    }

    black_hole = Object.new
    def black_hole.method_missing(*args)
      self
    end

    mailer_spy = Spy.on(MemberMailer, :with).and_return(black_hole)

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      notifier.send_daily_loan_summaries
    end

    days.times do |i|
      mailer_call = mailer_spy.calls.find { |c| c.args[0][:member].email == loans[i].member.email }
      if i % 7 == 0
        assert mailer_call
      else
        refute mailer_call
      end
    end
  end

  test "only mentions items that are checked out or returned that day" do
    returned_today = create(:loan, due_at: 1.day.ago, created_at: 8.days.ago, ended_at: Time.current)
    member = returned_today.member
    checked_out_today = create(:loan, member: member, due_at: 7.days.since)
    previous_loan = create(:ended_loan, member: member)

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      notifier.send_daily_loan_summaries
    end

    refute ActionMailer::Base.deliveries.empty?

    mail = ActionMailer::Base.deliveries.select { |delivery| delivery.to == [member.email] }.first
    assert_includes mail.encoded, returned_today.item.complete_number
    assert_includes mail.encoded, checked_out_today.item.complete_number
    refute_includes mail.encoded, previous_loan.item.complete_number
  end
end

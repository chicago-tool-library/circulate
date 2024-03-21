require "test_helper"

class ActivityNotifierTest < ActiveSupport::TestCase
  include Lending

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

  test "sends emails and texts to folks who have items due on the following day" do
    member = create(:verified_member, reminders_via_text: true)
    loan = Time.use_zone("America/Chicago") {
      create(:loan, member: member, due_at: (Time.current.end_of_day + 1.day), created_at: 6.days.ago)
    }

    Time.use_zone("America/Chicago") do
      # Loans not due tomorrow for other members shouldn't generate notifications
      create(:loan, due_at: Time.current.end_of_day, created_at: 6.days.ago)
      create(:loan, due_at: (Time.current.end_of_day - 1.day), created_at: 6.days.ago)
      create(:loan, due_at: (Time.current.end_of_day + 2.days), created_at: 6.days.ago)
      # Non-due loan for notified member shouldn't show up in SMS due count
      create(:loan, member: loan.member, due_at: (Time.current.end_of_day + 2.days), created_at: 6.days.ago)
    end

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      assert_difference "Notification.count", 2 do
        notifier.send_return_reminders
      end
    end

    assert mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == [loan.member.email] }

    assert_equal "Your items are due soon", mail.subject
    assert_includes mail.encoded, loan.item.complete_number

    text = TwilioHelper::FakeSMS.messages.last
    assert_includes text.to, loan.member.phone_number
    assert_includes text.body, "1 item due tomorrow"
  end

  test "doesn't send reminder emails or texts to folks who have returned their items" do
    member = create(:verified_member, reminders_via_text: true)
    Time.use_zone("America/Chicago") do
      create(:ended_loan, member: member, due_at: (Time.current.end_of_day + 1.day))
    end

    TwilioHelper::FakeSMS.messages.clear

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      assert_no_difference "Notification.count" do
        notifier.send_return_reminders
      end
    end

    assert ActionMailer::Base.deliveries.empty?
    assert TwilioHelper::FakeSMS.messages.empty?
  end

  test "doesn't send emails with old activity" do
    Time.use_zone("America/Chicago") do
      end_of_previous_day = Time.current.beginning_of_day - 1.minute

      travel_to end_of_previous_day do
        loan = create(:loan)
        assert return_loan(loan)
      end

      TwilioHelper::FakeSMS.messages.clear

      notifier = ActivityNotifier.new
      assert_no_difference "Notification.count" do
        notifier.send_daily_loan_summaries
      end
    end

    assert ActionMailer::Base.deliveries.empty?
  end

  test "sends overdue notice emails and texts only to folks with overdue items" do
    Time.use_zone("America/Chicago") do
      member = create(:verified_member, reminders_via_text: true)
      @overdue_loan = create(:loan, member: member, due_at: Time.current.end_of_day, created_at: 1.week.ago)
      @not_overdue_loan = create(:loan, due_at: Time.current.tomorrow.end_of_day, created_at: 6.days.ago)

      assert_difference "Notification.count", 2 do
        ActivityNotifier.new.send_overdue_notices
      end
    end

    mails = ActionMailer::Base.deliveries
    assert_equal 1, mails.count

    mail = mails.first
    assert_includes mail.to, @overdue_loan.member.email
    assert_not_includes mail.to, @not_overdue_loan.member.email

    assert_equal "You have overdue items!", mail.subject
    assert_includes mail.encoded, "return all overdue items as soon as possible"
    assert_includes mail.encoded, @overdue_loan.item.complete_number

    text = TwilioHelper::FakeSMS.messages.last
    assert_includes text.to, @overdue_loan.member.phone_number
    assert_includes text.body, "1 overdue item"
  end

  test "sends overdue notice emails that only contain overdue items" do
    Time.use_zone("America/Chicago") do
      @member = create(:verified_member, reminders_via_text: true)
      @overdue_loan = create(:loan, member: @member, due_at: Time.current.end_of_day, created_at: 1.week.ago)
      @not_overdue_loan = create(:loan, member: @member, due_at: Time.current.tomorrow.end_of_day, created_at: 6.days.ago)

      assert_difference "Notification.count", 2 do
        ActivityNotifier.new.send_overdue_notices
      end
    end

    mails = ActionMailer::Base.deliveries
    assert_equal 1, mails.count

    assert mail = mails.find { |mail| mail.to == [@member.email] }

    assert_equal "You have overdue items!", mail.subject
    assert_includes mail.encoded, "return all overdue items as soon as possible"
    assert_includes mail.encoded, @overdue_loan.item.complete_number
    assert_not_includes mail.encoded, @not_overdue_loan.item.complete_number
  end

  test "doesn't send overdue notices to folks with returned overdue items" do
    Time.use_zone("America/Chicago") do
      create(:ended_loan, due_at: Time.current.end_of_day)
      create(:ended_loan, due_at: Time.current.tomorrow.end_of_day)
    end

    TwilioHelper::FakeSMS.messages.clear

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      assert_no_difference "Notification.count" do
        notifier.send_overdue_notices
      end
    end

    assert ActionMailer::Base.deliveries.empty?
    assert TwilioHelper::FakeSMS.messages.empty?
  end

  test "only sends notices to folks with items that were due whole weeks ago" do
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

    def black_hole.respond_to_missing?(*args)
      true
    end

    mailer_spy = Spy.on(MemberMailer, :with).and_return(black_hole)
    texter_spy = Spy.on(MemberTexter, :new).and_return(black_hole)

    Time.use_zone("America/Chicago") do
      notifier = ActivityNotifier.new
      notifier.send_overdue_notices
    end

    days.times do |i|
      mailer_call = mailer_spy.calls.find { |c| c.kwargs[:member].email == loans[i].member.email }
      texter_call = texter_spy.calls.find { |c| c.args[0].email == loans[i].member.email }
      if i % 7 == 0
        assert mailer_call
        assert texter_call
      else
        refute mailer_call
        refute texter_call
      end
    end
  end

  test "rescues exceptions in overdue notices, sends to appsignal, and continues" do
    Time.use_zone("America/Chicago") do
      3.times { create(:loan, member: create(:verified_member, reminders_via_text: true), due_at: Time.current.end_of_day, created_at: 1.week.ago) }

      # Make MemberTexter.new explode one time then work
      error = Twilio::REST::TwilioError.new
      orig_method = MemberTexter.method(:new)
      call_count = 0
      explode_once = ->(member) {
        if call_count > 0
          orig_method.call(member)
        else
          call_count += 1
          raise error
        end
      }
      Spy.on(MemberTexter, :new).and_return(&explode_once)
      appsignal_spy = Spy.on(Appsignal, :send_error)

      # Blowing up 1 SMS, so should have 3 successful emails + 2 texts
      assert_difference "Notification.count", 5 do
        ActivityNotifier.new.send_overdue_notices
      end

      assert appsignal_spy.has_been_called_with?(error)
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

    mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == [member.email] }
    assert_includes mail.encoded, returned_today.item.complete_number
    assert_includes mail.encoded, checked_out_today.item.complete_number
    refute_includes mail.encoded, previous_loan.item.complete_number
  end

  test "sends emails to folks with rejected renewal requests" do
    loan = Time.use_zone("America/Chicago") {
      create(:loan, created_at: Time.current.beginning_of_day - 1.minute)
    }

    Time.use_zone("America/Chicago") do
      end_of_previous_day = Time.current.beginning_of_day - 1.minute

      travel_to end_of_previous_day do
        assert return_loan(loan)
      end

      create(:renewal_request, loan: loan, status: :rejected)

      notifier = ActivityNotifier.new
      notifier.send_daily_loan_summaries
    end

    refute ActionMailer::Base.deliveries.empty?

    mail = ActionMailer::Base.deliveries.find { |delivery| delivery.to == [loan.member.email] }
    refute mail.nil?

    assert_equal "Today's loan summary", mail.subject
    assert_includes mail.encoded, loan.item.complete_number
    refute_includes mail.encoded, "rejected"
  end
end

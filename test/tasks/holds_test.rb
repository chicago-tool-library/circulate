require "test_helper"
require "rake"

class HoldsTest < ActiveSupport::TestCase
  setup do
    Circulate::Application.load_tasks if Rake::Task.tasks.empty?
    ActionMailer::Base.deliveries.clear
  end

  test "notifies members of holds available via email and text" do
    hold = create(:hold, member: create(:verified_member, reminders_via_text: true))

    Rake::Task["holds:start_waiting_holds"].invoke

    mails = ActionMailer::Base.deliveries
    assert_equal 1, mails.count

    mail = mails.first
    assert_includes mail.to, hold.member.email

    assert_includes mail.subject, "One of your holds is available"
    assert_includes mail.encoded, hold.item.complete_number

    text = TwilioHelper::FakeSMS.messages.last
    assert_includes text.to, hold.member.phone_number
    assert_includes text.body, "Your hold for #{hold.item.complete_number} is available"
  end
end

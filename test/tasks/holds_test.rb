require "test_helper"
require "test_helpers/twilio_helper"
require "rake"

class HoldsTest < ActiveSupport::TestCase
  setup do
    Circulate::Application.load_tasks if Rake::Task.tasks.empty?
    ActionMailer::Base.deliveries.clear
    BaseTexter.client = TwilioHelper::FakeSMS.new
    TwilioHelper::FakeSMS.messages.clear
  end

  teardown do
    BaseTexter.client = nil
  end

  test "notifies members of holds available via email and text" do
    hold = create(:hold)

    Rake::Task["holds:start_waiting_holds"].invoke

    mails = ActionMailer::Base.deliveries
    assert_equal 1, mails.count

    mail = mails.first
    assert_includes mail.to, hold.member.email

    assert_includes mail.subject, "One of your holds is available"
    assert_includes mail.encoded, hold.item.complete_number

    texts = TwilioHelper::FakeSMS.messages
    assert_equal 1, texts.count

    text = texts.first
    assert_includes text.to, hold.member.phone_number
    assert_includes text.body, "Your hold for #{hold.item.complete_number} is available"
  end
end

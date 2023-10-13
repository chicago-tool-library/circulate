require "test_helper"

class MemberMailerTest < ActionMailer::TestCase
  include Lending

  setup do
    ActionMailer::Base.deliveries.clear
  end

  [:approved, :rejected].each do |status|
    test "renders renewal request #{status} email for a renewed loan" do
      item = create(:item, :with_image)
      loan = create(:loan, item: item)
      renewed_loan = renew_loan(loan)
      renewal_request = create(:renewal_request, loan: renewed_loan, status: status)

      email = MemberMailer.with(renewal_request: renewal_request).renewal_request_updated
      assert_emails 1 do
        email.deliver_later
      end
    end

    test "renders renewal request #{status} email for the first loan" do
      item = create(:item, :with_image)
      loan = create(:loan, item: item)
      renewal_request = create(:renewal_request, loan: loan, status: status)

      email = MemberMailer.with(renewal_request: renewal_request).renewal_request_updated
      assert_emails 1 do
        email.deliver_later
      end
    end
  end

  test "can deliver welcome email" do
    member = create(:member)
    email = MemberMailer.with(member: member).welcome_message

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "welcome email only renders footer once" do
    member = create(:member)
    email = MemberMailer.with(member: member).welcome_message

    footer_regexp = /See you at the library!/

    assert_equal 1, email.text_part.body.to_s.scan(footer_regexp).size
    assert_equal 1, email.html_part.body.to_s.scan(footer_regexp).size
  end

  test "welcome email recommends adding sender to contacts" do
    member = create(:member)
    email = MemberMailer.with(member: member).welcome_message

    add_to_contacts_regexp = /Please consider adding.*#{member.library.email}.*to your contacts/

    assert_match add_to_contacts_regexp, email.text_part.body.to_s
    assert_match add_to_contacts_regexp, email.html_part.body.to_s
  end

  test "can deliver membership reminder email" do
    member = create(:member)
    email = MemberMailer.with(member: member).membership_reminder

    assert_emails 1 do
      email.deliver_now
    end
  end

  test "can deliver renewal email" do
    member = create(:member)
    email = MemberMailer.with(member: member).renewal_message

    assert_emails 1 do
      email.deliver_now
    end
  end
end

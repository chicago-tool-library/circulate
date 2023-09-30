# frozen_string_literal: true

require "test_helper"

class MemberMailerTest < ActionMailer::TestCase
  include Lending

  setup do
    ActionMailer::Base.deliveries.clear
  end

  [:approved, :rejected].each do |status|
    test "renders renewal request #{status} email for a renewed loan" do
      item = create(:item, :with_image)
      loan = create(:loan, item:)
      renewed_loan = renew_loan(loan)
      renewal_request = create(:renewal_request, loan: renewed_loan, status:)

      email = MemberMailer.with(renewal_request:).renewal_request_updated
      assert_emails 1 do
        email.deliver_later
      end
    end

    test "renders renewal request #{status} email for the first loan" do
      item = create(:item, :with_image)
      loan = create(:loan, item:)
      renewal_request = create(:renewal_request, loan:, status:)

      email = MemberMailer.with(renewal_request:).renewal_request_updated
      assert_emails 1 do
        email.deliver_later
      end
    end
  end
end

require "application_system_test_case"

class AdminRenewalRequestsTest < ApplicationSystemTestCase
  setup do
    @member = create(:verified_member_with_membership)
    @item = create(:item)
    @loan = create(:loan, item: @item, member: @member)
    @renewal_request = create(:renewal_request, loan: @loan)

    ActionMailer::Base.deliveries.clear

    sign_in_as_admin
    visit admin_renewal_requests_url
  end

  test "viewing renewal requests" do
    within ".table" do
      assert_text @item.complete_number
    end
  end

  test "approving renewal requests" do
    perform_enqueued_jobs do
      click_on "Renew"

      within ".table" do
        assert_text "approved, due"
        refute_text "Renew"
      end
    end

    assert_text "Renewal request updated"

    assert_emails 1
    assert_delivered_email(to: @member.email) do |html, text|
      assert_includes html, "was approved"
    end
  end

  test "rejecting renewal requests" do
    perform_enqueued_jobs do
      click_on "Reject"

      within ".table" do
        assert_text "rejected"
        refute_text "Reject"
      end
    end

    assert_text "Renewal request updated"

    assert_emails 1
    assert_delivered_email(to: @member.email) do |html, text|
      assert_includes html, "aren't able to renew"
    end
  end
end

require "application_system_test_case"

class MembershipRenewalTest < ApplicationSystemTestCase
  def setup
    Document.create!(code: "borrow_policy", body: "This is the borrow policy", name: "Borrow Policy", summary: "bp")
    create(:agreement_document)

    @user = create(:user)
    @member = create(:verified_member, user: @user, email: "testuser#{rand(10000000)}@toollibrary.org")

    login_as @user

    ActionMailer::Base.deliveries.clear

    # This warning is generated on execution of complete_first_three_steps, and
    # it seems to be harmless. See
    # https://github.com/YusukeIwaki/capybara-playwright-driver/issues/51 for
    # discussion. The fix in the driver involves a puts which is noisy in test
    # outputs, so we suppress that here.
    suppress_puts([
      /Execution context was destroyed, most likely because of a navigation/
    ])
  end

  def teardown
    restore_puts
  end

  def complete_first_three_steps
    assert_selector "h1", text: "Membership Renewal"
    click_on "Renew Online"

    assert_selector "li.step-item.active", text: "Rules"
    click_on "Continue"

    assert_selector "li.step-item.active", text: "Profile"
    click_on "Save and Continue"

    assert_selector "h2", text: "Agreement"
    assert_selector "li.step-item.active", text: "Agreement"

    first("label", text: "I have read, understand, and agree to these terms.").click
    click_on "Continue"

    assert_selector "li.step-item.active", text: "Payment"
  end

  def complete_square_checkout
    click_on "Pay Online Now"

    wait_for_square_sandbox_to_load

    # Checkout API Sandbox Testing Panel
    # extract order id from page
    # p.text will be something like "order_id: xyu3Gv1KQic4q93xISrJusrHXa4F\nurl: https://sandbox.square.link/u/xUTx9ykD"
    p = page.find("p", text: "order_id")
    data = p.text.split.in_groups_of(2).to_h
    order_id = data["order_id:"]

    # advance through and complete the payment
    click_on "Next"

    # complete the payment so we can verify the callback
    click_on "Test Payment"
    assert_content "Checkout Complete"

    # grab redirect URL
    td = page.find("td", text: /redirected/)
    url = td.text.sub("Customer redirected to:", "").strip

    # build redirect URL from url and order id
    redirect_url = "#{url}?orderId=#{order_id}"

    perform_enqueued_jobs do
      visit redirect_url

      # Back in the app
      assert_selector "li.step-item.active", text: "Complete", wait: slow_op_wait_time
    end
  end

  test "renews membership that expires soon" do
    @membership = create(:membership, member: @member, created_at: 336.days.ago, started_at: 336.days.ago, ended_at: 29.days.since)
    visit account_home_url

    assert_content "Your membership ends on"
    click_on "Renew Membership"

    complete_first_three_steps

    perform_enqueued_jobs do
      click_on "Complete in Person"

      assert_selector "li.step-item.active", text: "Complete", wait: slow_op_wait_time
    end

    assert_emails 1
    assert_delivered_email(to: @member.email) do |html, text|
      assert_includes html, "Thank you for renewing"
      refute_includes html, "Your payment of"
    end
  end

  test "renewing before end and pay through square", :remote do
    @membership = create(:membership, member: @member, created_at: 336.days.ago, started_at: 336.days.ago, ended_at: 29.days.since)
    assert_equal 1, @member.memberships.count

    visit account_home_url

    assert_content "Your membership ends on"
    click_on "Renew Membership"

    complete_first_three_steps

    fill_in "Your membership fee:", with: "42"

    complete_square_checkout

    assert_content "Your payment of $42.00"
    assert_content "See you at the library!"

    assert_emails 1
    assert_delivered_email(to: @member.email) do |html, text|
      assert_includes html, "Thank you for renewing"
      assert_includes html, "Your payment of $42.00"
    end

    assert_equal 2, @member.memberships.count
    last_membership = @member.last_membership

    assert_equal "renewal", last_membership.membership_type
    assert last_membership.started_at
    assert last_membership.ended_at
  end

  test "renewing after end and pay through square", :remote do
    @membership = create(:membership, member: @member, created_at: 336.days.ago, started_at: 465.days.ago, ended_at: 100.days.ago)
    assert_equal 1, @member.memberships.count

    visit account_home_url

    assert_content "Your membership ended on"
    click_on "Renew Membership"

    complete_first_three_steps

    fill_in "Your membership fee:", with: "42"

    complete_square_checkout

    assert_content "Your payment of $42.00"
    assert_content "See you at the library!"

    @member.reload

    assert_emails 1
    assert_delivered_email(to: @member.email) do |html, text|
      assert_includes html, "Thank you for renewing"
      assert_includes html, "Your payment of $42.00"
    end

    assert_equal 2, @member.memberships.count
    last_membership = @member.last_membership

    assert_equal "renewal", last_membership.membership_type
    assert_in_delta Time.current, last_membership.started_at, 1.day
    assert_in_delta last_membership.ended_at, last_membership.started_at + 364.days, 1.day
  end

  test "renew with redeem a gift membership" do
    @membership = create(:membership, member: @member, created_at: 336.days.ago, started_at: 465.days.ago, ended_at: 100.days.ago)
    assert_equal 1, @member.memberships.count
    gift_membership = create(:gift_membership)

    visit account_home_url

    assert_content "Your membership ended on"
    click_on "Renew Membership"

    complete_first_three_steps

    click_on "Redeem Gift Membership"

    fill_in "gift_membership_redemption_form_code", with: gift_membership.code.value

    perform_enqueued_jobs do
      click_on "Redeem"

      assert_content "See you at the library!", wait: slow_op_wait_time
    end
    refute_content "Your payment"

    @member.reload

    assert_emails 1
    assert_delivered_email(to: @member.email) do |html, text|
      assert_includes html, "Thank you for renewing"
      refute_includes html, "Your payment"
    end

    assert_equal 0, @member.adjustments.count

    assert_equal 2, @member.memberships.count
    last_membership = @member.last_membership

    assert_equal "renewal", last_membership.membership_type
    assert last_membership.started_at
    assert_in_delta last_membership.ended_at, last_membership.started_at + 364.days, 25.hours # DST means days can have 25 hours
  end
end

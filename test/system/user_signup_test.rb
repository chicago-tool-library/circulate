require "application_system_test_case"
require "securerandom"

class UserSignupTest < ApplicationSystemTestCase
  def setup
    Document.create!(code: "borrow_policy", body: "This is the borrow policy", name: "Borrow Policy", summary: "bp")
    create(:agreement_document)
    ActionMailer::Base.deliveries.clear
  end

  def complete_first_three_steps
    email = "#{SecureRandom.alphanumeric}@test.com".downcase

    visit signup_url

    click_on "Sign Up as an Individual"

    assert_selector "li.step-item.active", text: "Rules"

    click_on "Continue"

    assert_selector "li.step-item.active", text: "Profile"

    fill_in "Full name", with: "N. K. Jemisin"
    fill_in "Preferred name", with: "Nora"
    find("label", text: "she/her").click # Styled checkboxes can't be toggled using #check
    fill_in "Email", with: email
    fill_in "Phone number", with: "312-123-4567"
    fill_in "Address", with: "23 N. Street"
    fill_in "Apt or unit", with: "390"
    fill_in "ZIP", with: "60647"
    fill_in "Password", with: "password", match: :prefer_exact
    fill_in "Password confirmation", with: "password", match: :prefer_exact

    click_on "Save and Continue"

    assert_selector "h2", text: "Agreement"
    assert_selector "li.step-item.active", text: "Agreement"

    first("label", text: "I have read, understand, and agree to these terms.").click
    click_on "Continue"

    assert_selector "li.step-item.active", text: "Payment"

    email
  end

  def complete_square_checkout
    ignore_js_errors reason: "square site has a couple issues" do
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
  end

  test "signup and complete in person" do
    email = complete_first_three_steps

    perform_enqueued_jobs do
      click_on "Complete in Person"

      assert_selector "li.step-item.active", text: "Complete", wait: slow_op_wait_time
    end

    assert_emails 1
    assert_delivered_email(to: email) do |html, text|
      assert_includes html, "Thank you for signing up"
      refute_includes html, "Your payment of"
    end
  end

  test "signs in after signup" do
    email = complete_first_three_steps

    perform_enqueued_jobs do
      click_on "Complete in Person"

      assert_selector "li.step-item.active", text: "Complete", wait: slow_op_wait_time
    end

    visit root_url

    within(".navbar-links") do
      click_on "Member Login"
    end

    fill_in "Email", with: email
    fill_in "Password", with: "password"

    click_on "Login"

    refute_selector "a", text: "Member Login"
    assert_selector "a", text: "Membership"
  end

  test "signup and pay through square", :remote do
    email = complete_first_three_steps

    fill_in "Your membership fee:", with: "42"

    complete_square_checkout

    assert_content "Your payment of $42.00"
    assert_content "See you at the library!"

    membership = Member.find_by(email: email).last_membership
    assert membership.pending?
    assert_equal "initial", membership.membership_type

    assert_emails 1
    assert_delivered_email(to: email) do |html, text|
      assert_includes html, "Thank you for signing up"
      assert_includes html, "Your payment of $42.00"
    end

    visit user_session_url

    fill_in :user_email, with: email
    fill_in :user_password, with: "password"
    click_on "Login"

    assert_text "Account Summary"
  end

  test "signup and redeem a gift membership" do
    email = complete_first_three_steps
    gift_membership = create(:gift_membership)

    click_on "Redeem Gift Membership"

    fill_in "gift_membership_redemption_form_code", with: gift_membership.code.value

    perform_enqueued_jobs do
      click_on "Redeem"

      assert_content "See you at the library!", wait: slow_op_wait_time
    end
    refute_content "Your payment"

    assert_emails 1
    assert_delivered_email(to: email) do |html, text|
      assert_includes html, "Thank you for signing up"
      refute_includes html, "Your payment"
    end

    member = Member.find_by(email: email)
    membership = member.last_membership

    assert_equal 0, member.adjustments.count
    assert membership.pending?
    assert_equal "initial", membership.membership_type
  end
end

require "application_system_test_case"

class UserSignupTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def setup
    Document.create!(code: "borrow_policy", body: "This is the borrow policy", name: "Borrow Policy", summary: "bp")
  end

  def assert_delivered_email(to:, &block)
    delivered_mail = ActionMailer::Base.deliveries.last
    assert_equal [to], delivered_mail.to

    html = delivered_mail.body.parts[0].body.to_s
    text = delivered_mail.body.parts[1].body.to_s
    yield html, text
  end

  def complete_first_three_steps
    visit signup_url

    click_on "Signup Online Now"

    assert_selector "li.step-item.active", text: "Rules"

    click_on "Continue"

    assert_selector "li.step-item.active", text: "Profile"

    fill_in "Full name", with: "N. K. Jemisin"
    fill_in "Preferred name", with: "Nora"
    select "she/her", from: "Pronoun"
    fill_in "Email", with: "nkjemisin@test.com"
    fill_in "Phone number", with: "312-123-4567"
    fill_in "ZIP code", with: "60647"

    click_on "Save and Continue"

    assert_selector "h2", text: "Agreement"
    assert_selector "li.step-item.active", text: "Agreement"

    first("label", text: "I have read, understand, and agree to these terms.").click
    click_on "Continue"

    assert_selector "li.step-item.active", text: "Payment"
  end

  test "signup and complete in person" do
    complete_first_three_steps

    perform_enqueued_jobs do
      click_on "Complete in Person"

      assert_selector "li.step-item.active", text: "Complete", wait: 5
    end

    assert_emails 1
    assert_delivered_email(to: "nkjemisin@test.com") do |html, text|
      assert_includes html, "Thank you for signing up"
      refute_includes html, "Your payment of"
    end
  end

  test "signup and pay through square" do
    complete_first_three_steps

    fill_in "Your membership fee:", with: "42"
    click_on "Pay Online Now"

    # On Square site

    assert_selector "h1", text: "Checkout", wait: 10 # cart needs a little while to fully load
    assert_selector ".order-details-section", text: "1 × Annual Membership"

    fill_in "card_fullname", with: "N. K. Jemisin"

    page.within_frame("sq-card-number") { page.first("input").fill_in with: "4111111111111111" }
    page.within_frame("sq-expiration-date") { page.find("input").fill_in with: "1221" }
    page.within_frame("sq-cvv") { page.find("input").fill_in with: "123" }
    page.within_frame("sq-postal-code") { page.first("input").fill_in with: "60647" }

    perform_enqueued_jobs do
      click_on "Place Order"

      # Back in the app
      assert_selector "li.step-item.active", text: "Complete", wait: 5
    end

    assert_content "Your payment of $42.00"
    assert_content "See you at the library!"

    assert_emails 1
    assert_delivered_email(to: "nkjemisin@test.com") do |html, text|
      assert_includes html, "Thank you for signing up"
      assert_includes html, "Your payment of $42.00"
    end
  end
end

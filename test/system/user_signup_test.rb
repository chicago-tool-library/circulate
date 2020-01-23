require "application_system_test_case"

class UserSignupTest < ApplicationSystemTestCase
  def setup
    Document.create!(code: "borrow_policy", body: "This is the borrow policy", name: "Borrow Policy", summary: "bp")
    ActionMailer::Base.deliveries.clear
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
    fill_in "Address", with: "23 N. Street"
    fill_in "Apt or unit", with: "390"
    fill_in "ZIP", with: "60647"

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

  test "signup and pay through square", :remote do
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
      assert_selector "li.step-item.active", text: "Complete", wait: 10
    end

    assert_content "Your payment of $42.00"
    assert_content "See you at the library!"

    assert_emails 1
    assert_delivered_email(to: "nkjemisin@test.com") do |html, text|
      assert_includes html, "Thank you for signing up"
      assert_includes html, "Your payment of $42.00"
    end
  end

  test "signup and redeem a gift membership" do
    complete_first_three_steps
    gift_membership = create(:gift_membership)

    click_on "Redeem Gift Membership"

    fill_in "signup_redemption_code", with: gift_membership.code.value

    perform_enqueued_jobs do
      click_on "Redeem"

      assert_content "See you at the library!", wait: 10
    end
    refute_content "Your payment"

    assert_emails 1
    assert_delivered_email(to: "nkjemisin@test.com") do |html, text|
      assert_includes html, "Thank you for signing up"
      refute_includes html, "Your payment"
    end

    assert_equal 0, Member.last.adjustments.count
  end
end

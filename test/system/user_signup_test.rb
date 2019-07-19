require "application_system_test_case"

class UserSignupTest < ApplicationSystemTestCase
  def complete_first_three_steps
    visit new_signup_member_url

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

    assert_selector "li.step-item.active", text: "Membership Fee"
  end

  test "signup and complete in person" do
    complete_first_three_steps

    click_on "Complete in Person"

    assert_selector "li.step-item.active", text: "Complete"
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

    click_on "Place Order"

    # Back in the app

    assert_selector "li.step-item.active", text: "Complete"
    assert_content "Thank you for your membership payment of $42.00!"
  end
end

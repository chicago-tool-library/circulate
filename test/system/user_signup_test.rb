require "application_system_test_case"

class UserSignupTest < ApplicationSystemTestCase
  test "entire flow" do
    visit new_signup_member_url
    assert_selector "h1", text: "Sign up"

    fill_in "Full name", with: "N. K. Jemisin"
    fill_in "Preferred name", with: "Nora"
    select "she/her", from: "Pronoun"

    fill_in "Email", with: "nkjemisin@example.com"
    fill_in "Phone number", with: "312-123-4567"
    fill_in "ZIP code", with: "60647"
    select "City key", from: "Photo ID"

    click_on "Save and Continue"

    assert_selector "h1", text: "Signup Complete!"
  end
end

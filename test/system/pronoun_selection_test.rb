require "application_system_test_case"

class PronounSelectionTest < ApplicationSystemTestCase
  def setup
    Document.create!(code: "borrow_policy", body: "This is the borrow policy", name: "Borrow Policy", summary: "bp")
  end

  test "select_multiple_pronouns" do
    visit signup_url

    click_on "Signup Online Now"

    click_on "Continue"

    fill_in "Full name", with: "N. K. Jemisin"
    fill_in "Preferred name", with: "Nora"
    check "she/her"
    check "he/him"
    check "they/them"
    fill_in "member[pronouns][]", with: "custom"
    fill_in "Email", with: "nkjemisin@test.com"
    fill_in "Phone number", with: "312-123-4567"
    fill_in "Address", with: "23 N. Street"
    fill_in "Apt or unit", with: "390"
    fill_in "ZIP", with: "60647"

    click_on "Save and Continue"

    first("label", text: "I have read, understand, and agree to these terms.").click
    click_on "Continue"

    assert_equal Member.last.pronouns, ["he/him", "she/her", "they/them", "custom"]
  end
end

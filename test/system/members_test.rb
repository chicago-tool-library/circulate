require "application_system_test_case"

class MembersTest < ApplicationSystemTestCase
  setup do
    @member = members(:one)
  end

  test "visiting the index" do
    visit members_url
    assert_selector "h1", text: "Members"
  end

  test "creating a Member" do
    visit members_url
    click_on "New Member"

    check "Address erified" if @member.address_erified
    fill_in "Custom", with: @member.custom_id
    fill_in "Custom pronoun", with: @member.custom_pronoun
    fill_in "Email", with: @member.email
    fill_in "Full name", with: @member.full_name
    fill_in "Id kind", with: @member.id_kind
    fill_in "Id number", with: @member.id_number
    fill_in "Notes", with: @member.notes
    fill_in "Phone number", with: @member.phone_number
    fill_in "Preferred name", with: @member.preferred_name
    fill_in "Pronoun", with: @member.pronoun
    click_on "Create Member"

    assert_text "Member was successfully created"
    click_on "Back"
  end

  test "updating a Member" do
    visit members_url
    click_on "Edit", match: :first

    check "Address erified" if @member.address_erified
    fill_in "Custom", with: @member.custom_id
    fill_in "Custom pronoun", with: @member.custom_pronoun
    fill_in "Email", with: @member.email
    fill_in "Full name", with: @member.full_name
    fill_in "Id kind", with: @member.id_kind
    fill_in "Id number", with: @member.id_number
    fill_in "Notes", with: @member.notes
    fill_in "Phone number", with: @member.phone_number
    fill_in "Preferred name", with: @member.preferred_name
    fill_in "Pronoun", with: @member.pronoun
    click_on "Update Member"

    assert_text "Member was successfully updated"
    click_on "Back"
  end

  test "destroying a Member" do
    visit members_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Member was successfully destroyed"
  end
end

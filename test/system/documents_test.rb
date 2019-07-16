require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  setup do
    @document = documents(:one)
  end

  test "visiting the index" do
    visit documents_url
    assert_selector "h1", text: "Documents"
  end

  test "updating a Document" do
    visit documents_url
    click_on "Edit", match: :first

    check "Active" if @document.active
    fill_in "Body", with: @document.body
    fill_in "Name", with: @document.name
    fill_in "Position", with: @document.position
    fill_in "Summary", with: @document.summary
    click_on "Update Document"

    assert_text "Document was successfully updated"
    click_on "Back"
  end
end
# frozen_string_literal: true

require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "adding a note to an item" do
    ignore_js_errors(reason: "This intentionally causes a 422 error") do
      @item = create(:item)
      visit admin_item_url(@item)

      click_on "Add a Note"
      click_on "Create Note"

      assert_content "can't be blank"

      fill_in_rich_text_area "note_body", with: "Information you should know"
      click_on "Create Note"

      assert_selector ".note", text: "Information you should know"
    end
  end

  test "editing a note on an item" do
    @item = create(:item)
    @note = create(:note, notable: @item, body: "this is a test")

    visit admin_item_url(@item)

    assert_content "this is a test"

    within ".note" do
      click_on "Edit"
    end

    fill_in_rich_text_area "note_body", with: "this is no longer a test"

    click_on "Update Note"

    refute_content "this is a test"
    assert_content "this is no longer a test"
  end
end

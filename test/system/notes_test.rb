require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "adding a note to an item" do
    @item = create(:item)
    visit admin_item_url(@item)

    fill_in_rich_text_area "note_body", with: "Information you should know"
    click_on "Create Note"

    assert_selector ".note", text: "Information you should know"
  end
end

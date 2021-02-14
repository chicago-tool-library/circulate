require "application_system_test_case"

class ItemAttachmentsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
    create(:default_borrow_policy)
  end

  test "adding an attachment to an item and then deleting it" do
    audited_as_admin do
      @item = create(:item)
    end

    visit admin_item_url(@item)
    click_on "Add File"

    attach_file "File", Rails.root + "test/fixtures/files/file.pdf"
    fill_in "Notes", with: "this is informative"
    click_on "Create"

    within ".item-stats" do
      assert_text "1 file"
    end

    assert_text "Manual"
    assert_text "this is informative"

    page.accept_confirm do
      click_on "Delete"
    end

    refute_text "View Manual"
    within ".item-stats" do
      assert_text "No files"
    end
    refute_text "this is informative"
  end
end

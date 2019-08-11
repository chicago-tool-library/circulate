require "application_system_test_case"

class TagsTest < ApplicationSystemTestCase
  setup do
    sign_in_as_admin
  end

  test "visiting the index" do
    visit admin_tags_url
    assert_selector "h1", text: "Tags"
  end

  test "creating a Tag" do
    visit admin_tags_url
    click_on "New Tag"

    fill_in "Name", with: "Tag Name"
    click_on "Create Tag"

    assert_text "Tag was successfully created"
    assert_text "Tag Name"
  end

  test "updating a Tag" do
    @tag = create(:tag)

    visit edit_admin_tag_url(@tag)

    fill_in "Name", with: "Modified Name"
    click_on "Update Tag"

    assert_text "Tag was successfully updated"
    assert_text "Modified Name"
  end

  test "destroying a Tag" do
    @tag = create(:tag)
    visit admin_tags_url

    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tag was successfully destroyed"
    refute_text @tag.name
  end
end

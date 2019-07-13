require "application_system_test_case"

class TagsTest < ApplicationSystemTestCase
  setup do
    @tag = tags(:one)
  end

  test "visiting the index" do
    visit tags_url
    assert_selector "h1", text: "Tags"
  end

  test "creating a Tag" do
    visit tags_url
    click_on "New Tag"

    fill_in "Name", with: @tag.name
    fill_in "Slug", with: @tag.slug
    click_on "Create Tag"

    assert_text "Tag was successfully created"
    click_on "Back"
  end

  test "updating a Tag" do
    visit tags_url
    click_on "Edit", match: :first

    fill_in "Name", with: @tag.name
    fill_in "Slug", with: @tag.slug
    click_on "Update Tag"

    assert_text "Tag was successfully updated"
    click_on "Back"
  end

  test "destroying a Tag" do
    visit tags_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Tag was successfully destroyed"
  end
end
